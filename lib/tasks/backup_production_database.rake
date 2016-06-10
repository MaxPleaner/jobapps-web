task :backup_production_database do
  puts "Pe"
  `heroku pg:backups capture`
  system("curl -o latest.dump `heroku pg:backups public-url`")
  `pg_restore --verbose --no-owner -h localhost -U max_pg -d JobappsWeb_development latest.dump`
end
