#!/usr/bin/env bats

setup() {
  export GEM_HOME='/tmp/awesome_blog/.gem'
}

@test 'it can bootstrap a Rails app' {
  run prototypical rails '/tmp/awesome_blog'
  echo "$output"
  [[ $status = 0 ]]
  [[ $output = *'Successfully installed bundler'* ]]
  [[ -d '/tmp/awesome_blog' ]]

  pushd '/tmp/awesome_blog' &>/dev/null
  run bin/rails generate model article title:string
  run bin/rake db:migrate
  run bin/rails runner 'Article.create(title: "First Article")'
  run bin/rails runner 'puts Article.first.title'
  [[ $output = 'First Article' ]]
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

