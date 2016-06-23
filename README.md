## About

This is a Rails app which is meant to help a job-seeker go through lists of companies, encouraging them to send out more job applications. It tracks the state of applications and can scrape job listings off [Indeed](indeed.com), [StackOverflow Jobs](http://stackoverflow.com/jobs), and [RemoteOK](http://remoteok.io).

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

## Usage notes

- All companies should at least have `name`, `desc`, and `category` set.
- Make sure to get YAML right the first time or back it up before importing.
- the `rake db:seed` command will look in the `db/seeds/yml/` folder (which won't necessarily exist) for `<category_name>.yml` files containing lists of companies. See the following example of a yaml file:
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

- There are a few rake tasks:
- `rake backup_production_database` syncs the local db with the production data
- `rake backup_database_to_yaml` backups the local db to yaml
- `rake import_database_from_yaml` loads yaml files in `/backup` into the local db. Basically the same as the `db/seeds.rb` but works with activerecord yaml dumps.

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

## Features

- Buttons to scrape listings from Indeed, StackOverflow, or RemoteOK.
- For Indeed and StackOverflow, the default query is 'ruby' but there is a form input for providing a custom query.
- A page to import companies from a YAML list.
- various 'filters' - applied, skipped, todos, starred
- "autoscroll" button - will scroll down to the "company details" part of the page
- "toggle categories" button - pick which categories of companies are shown. **Warning** this affects the default scope on companies, so if running a console when the server is also running, use `Company.unscoped.all` to __really__ get all the records.
- search button - It is __not__ scoped by "toggle categories", and will consider every company name in the database.
- "statistics" - scoped by  "toggle categories", this shows how far the user has progressed through their current set.
- "recently edited companies" shows the last 5 edits made.
- "previous company" and "next company" buttons
- "quick action" buttons to one-click apply, skip, todo, or star.
- update forms for individual companies
- new company form

## How it's built

Here are the custom gems in the Gemfile:

- [`rails_12factor`](https://github.com/heroku/rails_12factor): Stdout logging and asset serving
- [`fuzzy_match`](https://github.com/seamusabshere/fuzzy_match): String searching
- [`awesome_print`](https://github.com/awesome-print/awesome_print): pretty printing
- [`indeed-ruby`](https://github.com/indeedlabs/indeed-ruby): [Indeed](http://indeed.com)'s ruby gem
- [`open_uri_redirections`](https://github.com/open-uri-redirections/open_uri_redirections): helps with getting data from StackOverflow
- [`nokogiri`](http://www.nokogiri.org/) for parsing StackOverflow's XML data
- [`mechanize`](https://github.com/sparklemotion/mechanize) used to send HTTP requests to StackOverflow.
- [`activerecord-session_store`](https://github.com/rails/activerecord-session_store) prevents `CookieOverflow` errors when storing data in `session`.

There's also some front-end stuff:

- [bootstrap](http://getbootstrap.com) for CSS structure
- [telestrap](https://code.steadman.io/telestrap/) as bootstrap theme, though it's modified here to be much less flashy.

## Code organization

I try to write using Rails conventions as much as possible and to centralize code so that it's not necessary to poke all over to find what does what. In practice, this means that I sometimes write a lot of code in a single file.

- Models: [`Company`](./app/models/company.rb) and [`Category`](./app/models/company.rb)
- Controllers: [`Pages`](./app/controllers/pages_controller) (only one large controller file)
- Views: separated out into partials. The [`Pages#root`](./app/views/pages/root.html.erb) view is used the most (this is _almost_ a single page app), but there are a few other non-partial views: [`Pages#add_yaml_list`](./app/views/pages/add_yaml_list) and [`Pages#category_toggler`](./app/views/pages/category_toggler.html.erb).
- For configuration and custom modules, I try and only use the [`application.rb`](./config/application.rb) file, the [`config/initializers`](./config/initializers/) folder, or the [`lib/](./lib/)` folder.
- Here there is a bit of `awesome_print` configuration done in [`application.rb`](./config/application.rb) and a [`find_job_listings`](./lib/find_job_listings.rb) module in [`lib/`](./lib/).
- There are some rake tasks in [`lib/tasks`](./lib/tasks/)

## Development History

I've made a number of job application tracking systems. Each time I make one, I'm improving the functionality from the previous iteration.

1. Initially, I had a primitive Ruby REPL which used `loop` and `gets.chomp`.
2. I mostly scrapped this and redid it as [job_tracker_cli](https://github.com/maxpleaner/job_tracker_cli) using the `ripl` gem and my [ruby_cli_skeleton](https://github.com/maxpleaner/ruby_cli_skeleton) project.
3. I used this for a little while, but got tired of doing so much writing in the command line. I decided to redo the project using yaml files and called it [jobapps](https://github.com/maxpleaner/jobapps). This application offered the REPL functionality of the previous versions, but also featured an AngelList scraper and I amassed a list of thousands of companies.
4. This repo is the most recent iteration. It scraps the [ruby_cli_skeleton](https://github.com/maxpleaner/ruby_cli_skeleton) REPL in favor of Rails console, and foregoes YAML files in favor of SQL.

## Contributing:

Please raise an issue if things aren't working correctly. I'm not saying this app is perfect, but bugs are bugs.

## Screenshots

![screenshot](/jobapps-screenshot.png)

