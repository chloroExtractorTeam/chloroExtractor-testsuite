#!/usr/bin/env bats

FIRST_FILE="SRR5216995_1M_1.fastq"
SECOND_FILE="SRR5216995_1M_2.fastq"

@test "Existence of the first input dataset" {
  [ -e "$FIRST_FILE" ]
}

@test "Existence of the second input dataset" {
  [ -e "$SECOND_FILE" ]
}

@test "MD5-Sum of the first input dataset" {
     run md5sum "$FIRST_FILE"
     [[ $output =~ ^51244d493e0459b22f23ce38ba2252a1[[:space:]] ]]
}

@test "MD5-Sum of the second input dataset" {
     run md5sum "$SECOND_FILE"
     [[ $output =~ ^da45378160cc306fcdfb700dbbaad0f6[[:space:]] ]]
}

@test "chloroExtractor-Run creates fcg.fa" {
     run docker run --volume /tmp/bla:/data --name test_chloroExtractor_001 -it --rm -w /data chloroextractorteam/chloroextractor ptx -1 "$FIRST_FILE" -2 "$SECOND_FILE"
     [ -e /tmp/bla/fcg.fa ]
}

@test "chloroExtractor-Run results in expected fcg.fa" {
     run md5sum /tmp/bla/fcg.fa
     [[ $output =~ ^e45102f608a7457c6187b9685ade6c01[[:space:]] ]]
}