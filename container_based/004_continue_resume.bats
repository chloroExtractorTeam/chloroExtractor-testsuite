#!/usr/bin/env bats

FIRST_FILE="SRR5216995_1M_1.fastq"
SECOND_FILE="SRR5216995_1M_2.fastq"

@test "chloroExtractor-Run stops after jf0" {
     run docker run --volume /tmp/bla:/data --name test_chloroExtractor_001 -it --rm -w /data chloroextractorteam/chloroextractor ptx -1 "$FIRST_FILE" -2 "$SECOND_FILE" --stop-after jf0
}

@test "chloroExtractor-Run resumes after jf0 until jf1" {
     run docker run --volume /tmp/bla:/data --name test_chloroExtractor_001 -it --rm -w /data chloroextractorteam/chloroextractor ptx -1 "$FIRST_FILE" -2 "$SECOND_FILE" --continue jf0 --stop-after jf1
}
