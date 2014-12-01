[![Code Climate](https://codeclimate.com/repos/537fae616956806e630030c0/badges/44ece20df58646f706f7/gpa.png)](https://codeclimate.com/repos/537fae616956806e630030c0/feed)
[![Code Climate](https://codeclimate.com/repos/537fae616956806e630030c0/badges/44ece20df58646f706f7/coverage.png)](https://codeclimate.com/repos/537fae616956806e630030c0/feed)
[![Circle CI](https://circleci.com/gh/MobilityLabs/pdr-server/tree/master.png?circle-token=14a66f787d47b7a42850cbaf6e4fc873b31e4715)](https://circleci.com/gh/MobilityLabs/pdr-server)


#PDR Server
`pdr_server` is the API for the PD Redesign server. It also
consumes the `pdc_client` gem.  Which is an Angular client.

##Deploy
- run `bundle install` to ensure the latest `pdr_client` is being refrenced
- run `RAILS_ENV=production S3_KEY=i S3_SECRET=i bundle exec rake assets:precompile ROLLBAR_ENV=production ROLLBAR_TOKEN=xxxxx` to precompile assets
- Commit newly created assets to the repo and push to heroku
- push to heroku `git push heroku`.

##Specs
Specs are implemented with RSpec(3.x) and the `expect` syntax.
Specs can be run via `spring rspec` to run the test 
suite.
  - run `rake db:drop RAILS_ENV=test` to remove any test db
  - run `rake db:create RAILS_ENV=test` to remove any test db
  - run `rake db:schema:load RAILS_ENV=test`
  - run `bundle exec rspec`

This should be a one time database setup for the testing env

##Getting Started
  - Run `bundle install` to install dependencies
  - Run `rake db:create` to create database.
  - Import an existing database run `psql "pdr_dev" < db/data/pdr_dev.sql`
  - Run `rake db:migrate` to migrate the database
  - Start `rails` with `rails server`
  - Start `redis` with `redis-server /usr/local/etc/redis.conf` (OS X, `brew install redis`)
  - Start `sidekiq` with the `sidekiq` command


###Foreman
Alternatively, foreman can be used to start everything by running `foreman start`.  Note that 
redis server needs to start independently since its more a platform dependency


##Rake Tasks
The `rake db:create_default_toolkit` - task creates the default toolkits.
The `rake db:create_default_key_questions` - task creates the default key questions.
The `rake db:create_default_walk_throughs` - task creates the default walk throughs for the flyover feature.
