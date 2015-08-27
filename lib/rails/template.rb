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
Capybara.default_driver = :poltergeist
#Capybara.default_driver = :selenium
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

file '.travis.yml', <<-YAML
---
language: ruby
rvm:
  - #{ENV['RUBY_VERSION']}

bundler_args: --without development production --jobs 3 --retry 3
cache: bundler
before_script:
  - rake db:test:prepare
YAML

bundle 'binstubs rspec-core'
bundle 'exec spring binstub --all'
rake 'db:create db:migrate db:test:prepare'

git :init
