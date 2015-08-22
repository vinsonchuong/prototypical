#!/usr/bin/env bats

setup() {
  echo
}

teardown() {
  rm -rf '/tmp/awesome_blog'
}

@test 'it can bootstrap a Rails app' {
  gem uninstall --executables bundler

  lib/rails/install '/tmp/awesome_blog'
  skip
  [[ $status = 0 ]]
  [[ $output = *'Successfully installed bundler'* ]]
  [[ -d '/tmp/awesome_blog' ]]
  [[ -f '/tmp/awesome_blog/Gemfile' ]]
  skip

  cd '/tmp/awesome_blog'
  mkfifo server
  ./bin/rails server &>server
  cat server
}
