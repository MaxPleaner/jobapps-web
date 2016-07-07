class Company < ApplicationRecord

  def self.calculate_stats
    Company.unscoped.applied.group("DATE(created_at)").count
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
      { "name" => company.name, "id" => company.id, "status" => company.status }
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

  def self.dups(name)
    matches = Company.search(name)
    maximum_name_length = matches.map { |match| match['name'].length }.max
    maximum_id_length = matches.map { |match| match['id'].to_s.length }.max
    maximum_status_length = matches.map { |match| match['status'].to_s.length }.max
    matches.first(5).each do |match|
      match['status'].delete 'name'
      name = match['name'].rjust(maximum_name_length).white_on_black
      id   = match['id'].to_s.ljust(maximum_id_length)
      status_color = match['status'].to_s.include?('applied') ? :green : :red
      status = match['status'].to_s.send(status_color).ljust(maximum_status_length)
      puts "#{id} | #{name} | #{status}"
    end
  end

end
