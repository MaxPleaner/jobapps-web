task :backup_production_database do
  `heroku pg:backups capture`
  system("curl -o latest.dump `heroku pg:backups public-url`")
  `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U myuser -d mydb latest.dump`
end
