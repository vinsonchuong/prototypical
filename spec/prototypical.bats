#!/usr/bin/env bats

@test 'it echos the recipe and directory' {
  run prototypical rails foo
  [[ $status -eq 0 ]]
  [[ $output = 'rails foo' ]]
}
