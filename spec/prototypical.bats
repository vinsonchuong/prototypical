#!/usr/bin/env bats

@test 'it can bootstrap a Rails app' {
  run prototypical 'rails' '/tmp/awesome_blog'
  [[ $status = 0 ]]
  skip
  [[ -d '/tmp/awesome_blog' ]]

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
