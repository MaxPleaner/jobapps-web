## About

This is a Rails app which is meant to help a job-seeker go through lists of companies, encouraging them to send out more job applications. It tracks the state of applications and can scrape job listings off Indeed, StackOverflow, and RemoteOK.

## How to use

Requires Ruby 2.3 or greater, mainly because of the [safe navigation operator](https://bugs.ruby-lang.org/issues/11537)

```
git clone https://github.com/maxpleaner/jobapps-web
cd jobapps-web
bundle install
```

Setup Postgres and configure [config/database.yml](config/database.yml) then run:

```
rake db:create db:migrate
```

If you want to use the Indeed scraper, [go to their publisher page](http://www.indeed.com/publisher), make an account, then go to the [xml job search](https://ads.indeed.com/jobroll/xmlfeed) page to find a publisher number. Export this into the environment:

```
export INDEED_PUBLISHER_NUMBER=123456789
```

This could go in `.bashrc` or something so that it doesn't need to be repeatedly run.

Also export some environment variables for basic HTTP auth:

```
export HTTP_USERNAME=admin
export HTTP_PASSWORD=password
```

Then run `rails server` and visit `localhost:3000`.

## Features / Sitemap

- Buttons to scrape listings from Indeed, StackOverflow, or RemoteOK. For Indeed and StackOverflow, This currently searches for ruby / javascript programming jobs in san francisco, but you can configure the query in `lib/find_job_listings.rb`. RemoteOK just shows all listings. 
- A page to import companies from a YAML list.
- Various 'filters' - applied, skipped, todos, starred
- "autoscroll" button - will scroll down to the "action" part of the page
- "toggle categories" button - pick which categories of companies are shown. _Warning_ this affects the default scope on companies, so if running a console when the server is also running, use `Company.unscoped.all` to _really_ get all the records.
- search button - this uses the [fuzzy_match](https://github.com/seamusabshere/fuzzy_match) gem. It is _not_ scoped by "toggle categories", and will consider every company name in the database.
- "statistics" - scoped by  "toggle categories", this shows how far the user has progressed through their current set.
- "recently edited companies" should show the last 5 edits made. It is buggy though.
- "previous company" and "next company" buttons
- "quick action" buttons to one-click apply, skip, todo, or star.
- update forms for individual companies
- new company form

## Usage notes / other features
- All companies should at least have `name`, `desc`, and `category` set.
- Make sure to get YAML right the first time or back it up before importing.
- the `rake db:seed` command will look in the `db/seeds/yml/` folder for `<category_name>.yml` files containing lists of companies. See the following example of a yaml file:
```yml
---
- name: "ACME INK"
  desc: "Environmentally Conscious Fishing"
  jobs: "90K Mariner"
  skip: |
    I didn't apply to this job because I get seasick

- name: "Meat Labs"
  desc: "Mass Market Plant Lab"
  jobs: "101K Full-Stack Enginner"
  applied: |
    their food is so good
    jobs url: http://meat-labs.com/?jobs=javascript
```

There are a few rake tasks:
- `backup_production_database` syncs the local db with the production data
- `backup_database_to_yaml` backups the local db to yaml
- `import_database_from_yaml` loads yaml files in `/backup` into the local db. Basically the same as the `db/seeds.rb` but works with activerecord yaml dumps.

## Deploying to Heroku

The following script should suffice to get it running on Heroku:

```sh
heroku create;
git push heroku master;
heroku run rake db:migrate
heroku run rake db:seed
heroku run config:set HTTP_USERNAME=admin;
heroku run config:set HTTP_USERNAME=password;
heroku run config:set INDEED_PUBLISHER_NUMBER=123456789;
heroku config:add LOG_LEVEL=DEBUG
heroku open;
```

## Development History

I've made a number of job application tracking systems. Each time I make one, I'm improving the functionality from the previous iteration.

1. Initially, I had a primitive Ruby REPL which used `loop` and `gets.chomp`.
2. I mostly scrapped this and redid it as [job_tracker_cli](https://github.com/maxpleaner/job_tracker_cli) using the `ripl` gem and my [ruby_cli_skeleton](https://github.com/maxpleaner/ruby_cli_skeleton) project.
3. I used this for a little while, but got tired of doing so much writing in the command line. I decided to redo the project using yaml files and called it [jobapps](https://github.com/maxpleaner/jobapps). This application offered the REPL functionality of the previous versions, but also featured an AngelList scraper and I amassed a list of thousands of companies.
4. This repo is the most recent iteration. It scraps the [ruby_cli_skeleton](https://github.com/maxpleaner/ruby_cli_skeleton) REPL in favor of Rails console, and foregoes YAML files in favor of SQL.

## Contributing:

Please raise an issue if things aren't working correctly. I'm not saying this app is perfect, but bugs are bugs.

## Screenshots

![screenshot1](/Screenshot 2016-06-20 at 10.57.30 AM.png)
![screenshot2](/Screenshot 2016-06-20 at 10.57.40 AM.png)
![screenshot3](/Screenshot 2016-06-20 at 10.57.53 AM.png)

