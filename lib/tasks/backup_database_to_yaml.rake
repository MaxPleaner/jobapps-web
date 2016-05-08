task :backup_database_to_yaml => :environment do
  `mkdir backup`
  categories = Category.all
  categories.each do |category|
      companies = category.companies.map(&:attributes)
      File.open(
        "backup/#{category.name}.yml",
        "w"
      ) do |f|
        f.write(YAML.dump(companies))
      end
  end
end
