#!/usr/bin/env perl

use Test::More tests => 2;
use Test::Script::Run;

my ( $ret, $stdout, $stderr ) = run_script("ptx");

is($ret, 1, 'ptx without argument return with exit code 1');
ok($stderr =~ /required: --mates.*Usage/sm, 'ptx without argument prints a help message');
