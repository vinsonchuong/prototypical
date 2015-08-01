#!/usr/bin/env bats

@test 'it echos the recipe and directory' {
  [[ $(prototypical rails foo) = 'rails foo' ]]
}
