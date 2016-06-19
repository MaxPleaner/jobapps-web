task :backup_database_to_yaml => :environment do
  `mkdir backup`
   puts("tried to create backup/. Did not create if already exists")
  categories = Category.all
  categories.each do |category|
      companies = category.companies.map(&:attributes).map do |attrs|
        attrs.reduce({}) do |memo, (k,v)|
          memo[k] = v unless k.in?([
            :id, "id", :created_at, "created_at", :updated_at, "updated_at"
          ])|| v.blank?
          memo
        end
      end
      File.open(
        "backup/#{category.name}.yml",
        "w"
      ) do |f|
        f.write(YAML.dump(companies))
        puts "wrote #{companies.length} companies to backup/#{category.name}.yml"
      end
  end
end
