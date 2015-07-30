#!/usr/bin/env bats

@test 'it echos the input' {
  [[ $(prototypical -o 'hello') = 'hello' ]]
}
