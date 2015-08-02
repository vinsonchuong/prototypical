#!/usr/bin/env bats

@test 'it echos the recipe and directory' {
  run prototypical rails foo
  [[ $status = 0 ]]
  [[ $output = 'rails foo' ]]
}
