#!/usr/bin/env bats

@test "invoking ptx without parameters" {
  run docker run --volume /tmp/bla:/data --name test_chloroExtractor_001 -it --rm -w /data chloroextractorteam/chloroextractor ptx
  #[ "$status" -eq 0 ]
  [[ ${lines[0]} =~ "required: --mates" ]]
}
