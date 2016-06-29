class Company < ApplicationRecord

  def self.calculate_stats
    Company.unscoped.applied.reduce(Hash.new{ |k,v| v = 0}) do |hash, company|
      date_str = company.updated_at.strftime("%d - %b")
      hash.tap { |hash| hash[date_str] += 1 }
    end
  end

  def html_escaped(str)
    ERB::Util.html_escape(str)
  end

  def name=(val)
    val.is_a?(String) ? super(html_escaped(val)) : super(val)
  end
  def desc=(val)
    val.is_a?(String) ? super(html_escaped(val)) : super(val)
  end
  def jobs=(val)
    val.is_a?(String) ? super(html_escaped(val)) : super(val)
  end

  default_scope do
    if Category.where(hidden: true).any?
      where("category NOT IN (?)", Category.where(hidden: true).pluck(:name))
    else
      all
    end
  end

  def self.search(query)
    return [] if query.blank?
    match_names = FuzzyMatch.new(
      unscoped.all.pluck(:name), must_match_groupings: true
    ).find_all_with_score(query).map(&:first)
    match_records = unscoped.where(name: match_names)
    results = match_records.sort_by do |company|
      match_names.index company.name
    end.first(20).map do |company|
      { "name" => company.name, "id" => company.id }
    end
    results
    # Alternative way to find records by ids
    # and preserve ordering:
      # Something.find(array_of_ids).index_by(&:id).values_at(*array_of_ids)
  end

  def self.applied
    where("applied IS NOT NULL").where("(applied = '') IS FALSE").notrejected
  end
  def self.skipped
    where("skip IS NOT NULL").where("(skip = '') IS FALSE")
  end
  def self.todo
    where("todo IS NOT NULL").where("(todo = '') IS FALSE")
  end
  def self.rejected
    where("rejected IS NOT NULL").where("(rejected = '') IS FALSE")
  end
  def self.notrejected
    where("rejected IS NULL OR rejected = '' ")
  end
  def self.nonblank
    applied |\
    skipped |\
    todo    |\
    rejected
  end
  def self.blank
    where("applied IS NULL AND skip IS NULL AND todo IS NULL and rejected IS NULL")
  end

  validates :name, :desc, presence: true, allow_blank: false
  validates :name, uniqueness: true
  validates :category, presence: true, allow_blank: false

  def status
    [
      "todo", "skip", "rejected", "applied", "notlaughing", "starred"
    ].reduce({}) do |hash, attr|
      hash["name"] = name
      val = send(attr.to_sym)
      if val
        hash[attr] = val
      end
      next hash
    end
  end

  def get_next
    self.class.unscoped.where("id > ?", id).first
  end

  def get_previous
    self.class.unscoped.where("id < ?", id).last
  end

  def starred=(val)
    super(val || false)
  end

end

CompanyStats = Company.calculate_stats