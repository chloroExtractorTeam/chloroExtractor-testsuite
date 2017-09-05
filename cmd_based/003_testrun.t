#!/usr/bin/env perl

use strict;
use warnings;
use File::Temp;
use LWP::Simple;
use Archive::Extract;
use Digest::MD5;

use Test::More;
use Test::Script::Run;

my %files = (
    'SRR5216995_1M_1.fastq' => "51244d493e0459b22f23ce38ba2252a1",
    'SRR5216995_1M_2.fastq' => "da45378160cc306fcdfb700dbbaad0f6"
    );

my $filelocation = 'https://zenodo.org/record/884449/files/SRR5216995_1M.tar.bz2';

# Download the testset to a temporary folder
my $tempdir = File::Temp::tempdir();

my $downloadlocation = $tempdir."/SRR5216995_1M.tar.bz2";

my $code = getstore($filelocation, $downloadlocation);
my $ae = Archive::Extract->new( archive => $downloadlocation );

my $ok = $ae->extract( to => $tempdir ) || die $ae->error;

# check if the correct md5sums are downloadable
my $correct_checksums = 0;
foreach my $file (keys %files)
{
    my $md5 = Digest::MD5->new;
    my $filelocation = $tempdir.'/'.$file;
    open(my $fh, "<", $filelocation) || die "Unable to open file '$filelocation': $!\n";
    $md5->addfile($fh);
    close($fh) || die "Unable to close file '$filelocation': $!\n";

    my $md5hex = $md5->hexdigest();
    if ($md5hex eq $files{$file})
    {
	$correct_checksums++;
    }
    
    is($md5hex, $files{$file}, sprintf('Checksum of file %s is correct', $file));
}

# we can skip further testing, if the download is not correct
unless ($correct_checksums == int(keys %files))
{    
    diag("Since the download of the test set failed, no further tests are performed");
    done_testing;
    exit;
}

# prepare run command

my @arg = ();
my @filenames = map { $tempdir.'/'.$_ } (sort keys %files);
for(my $i = 1; $i <= @filenames; $i++)
{
    push(@arg, ("-".$i, $filenames[$i-1]));
}

my ($ret, $stdout, $stderr ) = run_script("bin/ptx", \@arg);
my $error_code = Test::Script::Run::last_script_exit_code();

diag($stdout);
diag($stderr);
diag("Error code: $error_code and return value $ret");

is($error_code, 0, 'Run of ptx returns 0 as error code');

done_testing;
