#!/usr/bin/env bats

setup() {
  export GEM_HOME='/tmp/awesome_blog/.gem'
}

@test 'it can bootstrap a Rails app' {
  run prototypical rails '/tmp/awesome_blog'
  [[ $status = 0 ]]

  [[ $output = *'Successfully installed bundler'* ]]

  [[ -d '/tmp/awesome_blog' ]]
  pushd '/tmp/awesome_blog' &>/dev/null

  run bin/rails generate model article title:string
  run bin/rake db:migrate
  run bin/rails runner 'Article.create(title: "First Article")'
  run bin/rails runner 'puts Article.first.title'
  [[ $output = 'First Article' ]]

  mkfifo server
  bin/rails server > server &
  while read line < server
  do
    if [[ $line = *'Listening on'* ]]
    then
      kill %%
    fi
  done
  # Exercise sass-rails with simple styling
  # Exercise jquery-rails with simple behavior

  # Deploy to CF / Heroku
  # Test uglified code
  # Test .travis.yml

  # Run RSpec

  run bin/spring status
  [[ $output = *'Spring is running:'* ]]

  run git status
  [[ $output = *'Initial commit'* ]]

  popd &>/dev/null
}

teardown() {
  if [[ -d '/tmp/awesome_blog' ]]
  then
    pushd '/tmp/awesome_blog'
    bin/spring stop
    popd
    rm -rf '/tmp/awesome_blog'
  fi

  gem clean &>/dev/null
  dropdb --if-exists 'awesome_blog_development'
  dropdb --if-exists 'awesome_blog_test'
}
