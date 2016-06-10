# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

require 'yaml'
require('colored')

Dir.glob(Rails.root.join("db/seeds/yml/**/*")).each do |filename|
  objects = YAML.load(File.read(filename))
  break unless objects
  objects.each do |company|
    record = Company.new({
      name: company["name"], 
      desc: company["desc"],
      applied: company["applied"],
      todo: company["todo"],
      skip: company["skip"],
      jobs: company["jobs"],
      rejected: company["rejected"],
      notlaughing: company["notlaughing"],
      category: filename.split("/")[-1].split(".yml").join
    })
    record.save
    errors = record.errors.full_messages
    record.persisted? ? ap(record) : ap(errors)
  end
end

Company.select(:category).distinct.pluck(:category).each do |category|
  Category.create(name: category, hidden: false)
end

if Company.count.eql?(0)
  # Every company's category attribute should correspond to a db/seeds/<category>.yml file.
  # Seeds are the only way to import companies into this app.
  companies_path = Rails.root.join("db/seeds/yml")
  `mkdir -p #{companies_path}`
  File.open("#{companies_path}/sample_category.yml", 'w') do |file|
    company = Company.create(
      name: "foo",
      desc: "bar",
      category: Category.create(name: "sample_category", hidden: false).name
    )
    file.write(YAML.dump([company.attributes]))
    puts "There were no companies in the database".yellow_on_black
    puts "Created a sample company in db/seeds/yml/sample_category.yml".yellow_on_black
    puts "------------\|".white_on_black + "Please run the rake db:seed command again.".yellow_on_black + "------------".white_on_black
  end
end
