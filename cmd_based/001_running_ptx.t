#!/usr/bin/env perl

use Test::More tests => 2;
use Test::Script::Run;

my ( $ret, $stdout, $stderr ) = run_script("bin/ptx");

is(Test::Script::Run::last_script_exit_code(), 2, 'ptx without argument return with exit code 1');
like($stderr, qr/required: --mates.*Usage/sm, 'ptx without argument prints a help message');
