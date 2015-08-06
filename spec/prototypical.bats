#!/usr/bin/env bats

setup() {
  echo
}

teardown() {
  rm -rf '/tmp/awesome_blog'
}

@test 'it can bootstrap a Rails app' {
  skip

  # stub something here

  run prototypical 'rails' '/tmp/awesome_blog'
  echo "$output"
  [[ $status = 0 ]]
  [[ -d '/tmp/awesome_blog' ]]
  [[ -f '/tmp/awesome_blog/Gemfile' ]]

  cd '/tmp/awesome_blog'
  mkfifo server
  ./bin/rails server &>server
  cat server
}

@test 'it shows an error message when an invalid recipe is given' {
  run prototypical 'invalid-recipe' '/tmp/awesome_blog'
  [[ $status = 1 ]]
  [[ $output = 'Please specify a valid recipe.' ]]
  [[ ! -d '/tmp/awesome_blog' ]]
}
