def bundle(command)
  Bundler.with_clean_env do
    run "bundle #{command}"
  end
end

file 'Gemfile', <<-RUBY
source 'https://rubygems.org'

ruby '#{ENV['RUBY_VERSION']}'
gem 'rails', '#{ENV['RAILS_VERSION']}'

gem 'pg'
gem 'puma'

gem 'bcrypt'
gem 'jbuilder'

gem 'sass-rails'
gem 'jquery-rails'
gem 'uglifier'

group :development do
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'spring-commands-rspec'

  gem 'pry-rails'
  gem 'web-console'
end

group :development, :test do
  gem 'byebug'
  gem 'pry-byebug'

  gem 'rspec-rails'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'poltergeist'
  gem 'phantomjs', require: 'phantomjs/poltergeist'
  gem 'selenium-webdriver'
end
RUBY

bundle 'install --jobs 4 --retry 3'

copy_file 'app/assets/stylesheets/application.css', 'app/assets/stylesheets/application.css.scss'
remove_file 'app/assets/stylesheets/application.css'
gsub_file 'app/assets/stylesheets/application.css.scss', /^.*=require.*\n/, ''

generate 'rspec:install'

insert_into_file 'spec/rails_helper.rb', <<-RUBY, after: /^# Add additional.*\n/
require 'capybara/rails'
require 'capybara/poltergeist'
# Capybara.default_driver = :poltergeist
Capybara.default_driver = :selenium
RUBY

comment_lines 'spec/rails_helper.rb', /use_transactional_fixtures/

insert_into_file 'spec/rails_helper.rb', <<-RUBY, after: /use_transactional_fixtures.*\n/
  config.before { DatabaseCleaner.strategy = :transaction }
  config.before(type: :feature) { DatabaseCleaner.strategy = :truncation }
  config.before { DatabaseCleaner.start }
  config.after { DatabaseCleaner.clean }
RUBY

gsub_file 'spec/spec_helper.rb', "=begin\n", ''
gsub_file 'spec/spec_helper.rb', "=end\n", ''
gsub_file 'spec/spec_helper.rb', '"spec/examples.txt"', %q['tmp/spec/examples.txt']

file '.travis.yml', <<YAML
---
language: ruby
rvm:
  - #{ENV['RUBY_VERSION']}

before_install:
  - export DISPLAY=:99.0
  - sh -e /etc/init.d/xvfb start

bundler_args: --without development production --jobs 3 --retry 3

before_script:
  - rake db:test:prepare

cache: bundler
YAML

bundle 'binstubs rspec-core'
bundle 'exec spring binstub --all'
rake 'db:create db:migrate db:test:prepare'

remove_file 'README.rdoc'
append_to_file 'README.md', <<MARKDOWN
[![Dependency Status](https://gemnasium.com/#{ENV['github_username']}/#{ENV['project_dir']}.svg)](https://gemnasium.com/#{ENV['github_username']}/#{ENV['project_dir']})
[![Code Climate](https://codeclimate.com/github/#{ENV['github_username']}/#{ENV['project_dir']}/badges/gpa.svg)](https://codeclimate.com/github/#{ENV['github_username']}/#{ENV['project_dir']})

## Development
The application requires the following external dependencies:
* PostgreSQL
* Ruby #{ENV['RUBY_VERSION']}
* Bundler

The rest of the dependencies are handled through:
```bash
bundle install
```

Bootstrap the database with:
```bash
bin/rake db:setup
```

You should not be able to run tests and start the application:
```bash
bin/rake
bin/rails server
```
MARKDOWN

run 'spring stop'
