## Introduction

I have a project called "jobapps" which I've been repeatedly refactoring.

I first wrote a ruby CLI using `loop` and `gets.chomp`.

I eventually found the `ripl` gem and used it to build a [ruby_cli_skeleton](http://github.com/maxpleaner/ruby_cli_skeleton). I redid the jobapps program using this CLI skeleton and called it [job_tracker_cli](http://github.com/maxpleaner/job_tracker_cli).

I then gave the project a third iteration, focusing on editable YAML files. This project is [jobapps](http://github.com/maxpleaner/jobapps). It still uses the `ruby_cli_skeleton`, but it focuses on using human-readable data serialization and text editors to work more productively. 

One morning I wanted to apply to jobs but thought it was time my jobapps project got a web interface.

## Setting up the companies database

This web interface doesn't actually have a way to add companies.  I didn't need this feature because I already had YAML files listing 2500 local startups. _See the [http://github.com/maxpleaner/jobapps](http://github.com/maxpleaner/jobapps) for information on how to construct such a list_.

To add some companies, create a `db/seeds/yml` folder and put YAML files there. The name of the yaml file (i.e. `san_francisco` for `san_francisco.yml`) becomes the category for all companies the file contains. See [db/seeds.rb](db/seeds.rb) to inspect / edit the import script.

The required keys on each company object are `name` and `desc`. `category` is inferred from the filename. Optional keys are `applied`, `todo`, `skip`, `jobs`, `rejected`, and `notlaughing`. 

The web application uses the following query methods to select companies:  
- `Company.blank` (where `applied`, `todo`, `skip`, and `rejected` are all falsey)
- `Company.nonblank` (where any of `applied`, `todo`, `skip`, or `rejected` are truthy)
- `Company.applied` (where `applied` is truthy)
- `Company.skipped` (where `skip` is truthy)
- `Company.rejected` (where `rejected` is truthy)
- `Company.todos` (where `todo` is truthy)

See the following example of a yaml file:

```yml
---
- name: "ACME INK"
  desc: "Environmentally Conscious Fishing"
  jobs: "90K Mariner"
  skip: |
    I didn't apply to this job because I get seasick

- name: "Company Two"
  desc: "Illuminati"
  jobs: "100K, Janitor"
  skip: true

- name: "Meat Labs"
  desc: "Mass Market Plant Lab"
  jobs: "101K Full-Stack Enginner"
  applied: |
    their food is so good
    jobs url: http://meat-labs.com/?jobs=javascript

- name: "NSA"
  desc: "Your favorite spy service"
  jobs: "Microcontroller Engineer"
  rejected: true
  notlaughing: "failed the background check"
```

## Running & Deploying the Rails App

Please consider forking the project if you use it.

This app is built with Rails 5. It uses the [safe navigation operator](https://bugs.ruby-lang.org/issues/11537), which requires Ruby 2.3 or greater. If you are using something greater than 2.3, you can run the app locally by commenting out the `ruby 2.3.0` line in the Gemfile. This line needs to present for Heroku to run the app though.

Setting up locally

```sh
git clone https://github.com/maxpleaner/jobapps-web;
cd jobapps-web;
bundle;
rake db:create db:migrate db:seed;
export HTTP_USERNAME=admin;
export HTTP_PASSWORD=password;
rails s;

```

Deploying to Heroku.

```sh
heroku create;
git push heroku master;
heroku run rake db:migrate
heroku run rake db:seed
heroku run config:set HTTP_USERNAME=admin;
heroku run config:set HTTP_USERNAME=password;
heroku config:add LOG_LEVEL=DEBUG
heroku open;
```

## How the app is structured

- HTTP basic auth via the `HTTP_USERNAME` and `HTTP_PASSWORD` environment variables
- There's two models, `Company` and `Category`
- There's a single controller, `PagesController`, which has a few routes:
  - `GET /` (root action - handles most HTML views)
  - `POST /update` (update action: redirects to corresponding HTML page)
  - `POST /category_toggler` (HTML view to toggle categories' visibility)
- the [awesome_print](https://github.com/michaeldv/awesome_print) provides a few helpful methods:
  - `Object.ai(html: true)` produces a html-formatted snapshot of an object.
  - `ap <object>` is a prettier alternative to `puts`
- There are no initializers, rake tasks, or tests yet. A bit of `awesome_print` customization is done in [config/application.rb](config/application.rb)

## Updates / Features

- the UI is updated so it is almost tolerable
- Switch between query views: todos, blanks, skips, or all companies. This setting is stored in `session`
- Statistics: percent completion, todos count, applied, count, skip count, blank count
- Recently edited companies list
- Add company form
- Previous/Next company buttons
- Forms to update records
- Autoscroll option (stored in `session`) brings the users focus to the content instantly (reducing the need for manual scrolling)
- Categories can be toggled on/off. This works using a dynamic `default_scope` on the `Company` model. 

## Note

I hope to keep this repo working out-the-box (except for the whole get-yaml-lists-of-companies thing). If there are any issues, please _raise an issue_. 