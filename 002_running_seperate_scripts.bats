#!/usr/bin/env bats

@test "invoking ptx with version parameter" {
  run docker run --volume /tmp/bla:/data --name test_chloroExtractor_001 -it --rm -w /data chloroextractorteam/chloroextractor ptx --version
  #[ "$status" -eq 0 ]
  regexp='[0-9]*\.[0-9]*'
  [[ ${lines[0]} =~ $regexp ]]
}

@test "invoking scale_reads.pl with version parameter" {
  run docker run --volume /tmp/bla:/data --name test_chloroExtractor_001 -it --rm -w /data chloroextractorteam/chloroextractor scale_reads.pl --version
  #[ "$status" -eq 0 ]
  regexp='[0-9]*\.[0-9]*'
  [[ ${lines[0]} =~ $regexp ]]
}

@test "invoking kmer_filter_reads.pl with version parameter" {
  run docker run --volume /tmp/bla:/data --name test_chloroExtractor_001 -it --rm -w /data chloroextractorteam/chloroextractor kmer_filter_reads.pl
  #[ "$status" -eq 0 ]
  regexp='required: --kmer-hash'
  [[ ${lines[0]} =~ $regexp ]]
}

@test "invoking assemble_spades.pl with version parameter" {
  run docker run --volume /tmp/bla:/data --name test_chloroExtractor_001 -it --rm -w /data chloroextractorteam/chloroextractor assemble_spades.pl --version
  #[ "$status" -eq 0 ]
  regexp='[0-9]*\.[0-9]*'
  [[ ${lines[0]} =~ $regexp ]]
}

@test "invoking find_cyclic_graph.pl with version parameter" {
  run docker run --volume /tmp/bla:/data --name test_chloroExtractor_001 -it --rm -w /data chloroextractorteam/chloroextractor find_cyclic_graph.pl --version
  #[ "$status" -eq 0 ]
  regexp='[0-9]*\.[0-9]*'
  [[ ${lines[0]} =~ $regexp ]]
}

