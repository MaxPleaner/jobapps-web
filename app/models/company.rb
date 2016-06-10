class Company < ApplicationRecord

  validates :name, uniqueness: true

  has_many :responses

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
      all.pluck(:name), must_match_groupings: true
    ).find_all_with_score(query).map(&:first)
    match_records = where(name: match_names)
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
    where("applied IS NOT NULL").where("(applied = '') IS FALSE")
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

  def status
    [
      :todo, :skip, :rejected, :applied, :notlaughing, :starred
    ].reduce({}) do |hash, attr|
      val = send(attr)
      if val
        hash[:name] = name
        hash[attr] = val
      end
      next hash
    end
  end

  def name=(val)
    super(val || "")
  end
  def desc=(val)
    super(val || "")
  end
  def applied=(val)
    super(val || "")
  end
  def skip=(val)
    super(val || "")
  end
  def rejected=(val)
    super(val || "")
  end
  def notlaughing=(val)
    super(val || "")
  end
  def category=(val)
    super(val || "")
  end
  def jobs=(val)
    super(val || "")
  end
  def starred=(val)
    super(val || false)
  end

end
