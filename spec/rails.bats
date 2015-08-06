#!/usr/bin/env bats

setup() {
  echo
}

teardown() {
  rm -rf '/tmp/awesome_blog'
}

@test 'it can bootstrap a Rails app' {
  run lib/rails/install '/tmp/awesome_blog'
  [[ $status = 0 ]]
  [[ -d '/tmp/awesome_blog' ]]
  [[ -f '/tmp/awesome_blog/Gemfile' ]]
  skip

  cd '/tmp/awesome_blog'
  mkfifo server
  ./bin/rails server &>server
  cat server
}
