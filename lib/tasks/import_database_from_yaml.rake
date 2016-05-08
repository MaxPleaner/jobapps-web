task :import_database_from_yaml => :environment do
  Dir.glob(Rails.root.join("backup", "**/*")).each do |file|
    companies = YAML.load(File.read(file))
    companies.each do |company|
      Company.create(company)
    end
  end
  Company.all.pluck(:category).uniq.each do |category|
    Category.create(name: category, hidden: false)
  end
end

