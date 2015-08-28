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

file '.travis.yml', <<'YAML'
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

remove_file 'README.rdoc'
file 'README.md', <<'MARKDOWN'
# Name of App
Travis CI Badge

## Section 1

## Section 2
MARKDOWN

file 'LICENSE', <<TEXT
The MIT License (MIT)

Copyright (c) #{Time.now.year} Vinson Chuong

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
TEXT

git :init
