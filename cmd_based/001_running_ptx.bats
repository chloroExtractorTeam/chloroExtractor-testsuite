#!/usr/bin/env bats

@test "invoking ptx without parameters" {
  run ptx
  #[ "$status" -eq 0 ]
  [[ ${lines[0]} =~ "required: --mates" ]]
}
