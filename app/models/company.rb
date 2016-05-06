class Company < ApplicationRecord

  default_scope do
    if Category.where(hidden: true).any?
      where("category NOT IN (?)", Category.where(hidden: true).pluck(:name))
    else
      all
    end
  end

  def self.applied
    where("applied IS NOT NULL")
  end
  def self.skipped
    where("skip IS NOT NULL")
  end
  def self.todo
    where("todo IS NOT NULL")
  end
  def self.rejected
    where("rejected IS NOT NULL")
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
      :todo, :skip, :rejected, :applied, :notlaughing
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
