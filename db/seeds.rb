# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).Dir.glob(Rails.root.join("db/seeds/yml/**/*")).each do |filename|
  objects = YAML.load(File.read(filename))
  objects.each do |company|
    ap Company.create(
      name: company["name"],
      desc: company["desc"],
      applied: company["applied"],
      todo: company["todo"],
      skip: company["skip"],
      jobs: company["jobs"],
      rejected: company["rejected"],
      notlaughing: company["notlaughing"],
      category: filename.split("/")[-1].split(".yml").join
    )
  end
end

Company.select(:category).distinct.pluck(:category).each do |category|
  Category.create(name: category, hidden: false)
end

if Company.count.eql?(0)
  Company.create(name: "foo", desc: "bar", category: Category.create(name: "foo-category", hidden: false).name)
end