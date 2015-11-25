# Welcome to PDredesign
PDredesign is a digital toolkit for school districts dedicated to improving professional development for educators. The toolkit, including collaborative assessments and inventories, is freely available on PDredesign.org and can be used by any school district to transform existing professional development systems to better support teachers in the classroom. The PDredesign tools were co-designed by district leaders through a collaborative process facilitated by Alvarez & Marsal. Mobility Labs is bringing the PDredesign Toolkit online to enable any district to leverage the tools. PDredesign was developed with support from the Bill & Melinda Gates Foundation.

## pdredesign-server
`pdredesign-server` is the API for the [PDredesign website](http://pdredesign.org). It also
consumes the [`pdredesign-client` gem](https://github.com/MobilityLabs/pdredesign-client).  Which is an Angular client.

## Getting Started
  - Run `bundle install` to install dependencies
  - Run `rake db:create` to create database.
  - Import an existing database run `psql "pdr_dev" < db/data/pdr_dev.sql`
  - Run `rake db:migrate` to migrate the database
  - Start `rails` with `rails server`
  - Start `redis` with `redis-server /usr/local/etc/redis.conf` (OS X, `brew install redis`)
  - Start `sidekiq` with the `sidekiq` command

### Foreman
Alternatively, foreman can be used to start everything by running `foreman start`.  Note that 
redis server needs to start independently since its more a platform dependency

### Deploy
- run `bundle install` to ensure the latest `pdr_client` is being refrenced
- run `RAILS_ENV=production S3_KEY=i S3_SECRET=i bundle exec rake assets:precompile ROLLBAR_ENV=production ROLLBAR_TOKEN=xxxxx` to precompile assets
- Commit newly created assets to the repo and push to heroku
- push to heroku `git push heroku`.

### Specs
Specs are implemented with RSpec(3.x) and the `expect` syntax.
Specs can be run via `spring rspec` to run the test 
suite.
  - run `rake db:drop RAILS_ENV=test` to remove any test db
  - run `rake db:create RAILS_ENV=test` to remove any test db
  - run `rake db:schema:load RAILS_ENV=test`
  - run `bundle exec rspec`

This should be a one time database setup for the testing env

### Rake Tasks
The `rake db:create_default_toolkit` - task creates the default toolkits.
The `rake db:create_default_key_questions` - task creates the default key questions.

## Contributing
We encourage you to contribute to the development of PDredesign. Please look at our Contributing guide for guidelines on how to proceed.

## Code Status
[![Circle CI](https://circleci.com/gh/MobilityLabs/pdredesign-server/tree/master.png?circle-token=14a66f787d47b7a42850cbaf6e4fc873b31e4715)](https://circleci.com/gh/MobilityLabs/pdredesign-server)

## License
PDredesign is released under the [MIT License](http://opensource.org/licenses/MIT).
