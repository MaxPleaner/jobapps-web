A web interface to my other jobapps project ([link](http://github.com/maxpleaner/jobapps))

This loads files from the `db/seeds/yml` folder, which won't be found on this git repo. See the other project for how to structure the files in this directory. Once they are there, run `rake db:seed`

All in all it's a very simple and generic rails app.

There requires the HTTP_USERNAME and HTTP_PASSWORD environment variables for the basic http auth.

Other than that there's a single model ("Company") and a single controller ("Pages"). For style there's bootstrap. `awesome_print` is used present data.

It's made on Postgres so it can be deployed to Heroku. Indeed, that's how I'm using it.

The Gemfile requires ruby 2.3 to enable the use of the safe navigation operator. It might not be found much throughout the code, but I like it enough to make 2.3 a dependency. 



