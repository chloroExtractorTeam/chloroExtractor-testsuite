#!/usr/bin/env perl

use Test::More;
use Test::Script::Run;

my @test_list = (
    { script => "ptx"                 , arg => ["--version"], exp_ret => 0, exp_stdout => qr/^\d+\.\d+$/ },
    { script => "scale_reads.pl"      , arg => ["--version"], exp_ret => 0, exp_stdout => qr/^\d+\.\d+$/ },
    { script => "kmer_filter_reads.pl", arg => ["--version"], exp_ret => 1, exp_stderr => qr/Unknown option: version/m },
    { script => "assemble_spades.pl"  , arg => ["--version"], exp_ret => 0, exp_stdout => qr/^\d+\.\d+$/ },
    { script => "find_cyclic_graph.pl", arg => ["--version"], exp_ret => 0, exp_stdout => qr/^\d+\.\d+$/ }
    );

foreach my $testset (@test_list)
{
    my ( $ret, $stdout, $stderr ) = run_script($testset->{script}, $testset->{arg});

    is($ret, $testset->{exp_ret}, sprintf('%s with argument %s return with exit code %d', $testset->{script}, join(", ", @{$testset->{arg}}), $testset->{exp_ret}));
    if (exists $testset->{exp_stdout})
    {
	like($stdout, $testset->{exp_stdout}, sprintf('%s with argument %s return with expected output', $testset->{script}, $testset->{arg}));
    }

    if (exists $testset->{exp_stderr})
    {
	like($stderr, $testset->{exp_stderr}, sprintf('%s with argument %s return with expected stderr', $testset->{script}, $testset->{arg}));
    }
}

done_testing;
