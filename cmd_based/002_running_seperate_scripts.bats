#!/usr/bin/env bats

@test "invoking ptx with version parameter" {
  un ptx --version
  #[ "$status" -eq 0 ]
  regexp='[0-9]*\.[0-9]*'
  [[ ${lines[0]} =~ $regexp ]]
}

@test "invoking scale_reads.pl with version parameter" {
  run scale_reads.pl --version
  #[ "$status" -eq 0 ]
  regexp='[0-9]*\.[0-9]*'
  [[ ${lines[0]} =~ $regexp ]]
}

@test "invoking kmer_filter_reads.pl with version parameter" {
  run kmer_filter_reads.pl
  #[ "$status" -eq 0 ]
  regexp='required: --kmer-hash'
  [[ ${lines[0]} =~ $regexp ]]
}

@test "invoking assemble_spades.pl with version parameter" {
  run assemble_spades.pl --version
  #[ "$status" -eq 0 ]
  regexp='[0-9]*\.[0-9]*'
  [[ ${lines[0]} =~ $regexp ]]
}

@test "invoking find_cyclic_graph.pl with version parameter" {
  run find_cyclic_graph.pl --version
  #[ "$status" -eq 0 ]
  regexp='[0-9]*\.[0-9]*'
  [[ ${lines[0]} =~ $regexp ]]
}

