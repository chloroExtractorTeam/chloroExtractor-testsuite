#!/usr/bin/env perl

use strict;
use warnings;
use File::Temp;
use LWP::Simple;
use Archive::Extract;
use Digest::MD5;
use List::Util qw(shuffle);

use Test::More;
use Test::Script::Run;

my %files = (
    'at_simulated1.fq' => "dbbf681985a6ef987e9a02a96c4c1a36",
    'at_simulated2.fq' => "0f9a9d0161ef185b7610978d7fe8b31f"
    );

my $filelocation = 'https://github.com/chloroExtractorTeam/simulate/releases/download/v1.0reduced/v1.0reduced_result.tar.bz2';

# Download the testset to a temporary folder
my $tempdir = File::Temp::tempdir();

my $downloadlocation = $tempdir."/v1.0reduced_result.tar.bz2";

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

# where are the input reads
my @filenames = map { $tempdir.'/'.$_ } (sort keys %files);

# scramble the read input files
diag("Scrambling the input reads");
my %dat = ();
my $num_reads = 0;
# read input
foreach my $file (@filenames)
{
    open(FH, "<", $file) || die($!);
    while (! eof(FH))
    {
	my $h  = <FH>;
	my $s  = <FH>;
	my $h2 = <FH>;
	my $q  = <FH>;

	push(@{$dat{$file}}, $h.$s.$h2.$q);
    }
    close(FH) || die ($!);

    if ($num_reads == 0)
    {
	$num_reads = scalar @{$dat{$file}};
    } else {
	die "Different number of reads" if ($num_reads != scalar @{$dat{$file}});
    }
}

# generate new read order
my $sran_ini = 641614629; # from random.org (number between 100000 and 1000000000)
srand($sran_ini);

diag("Random number generator initiated with $sran_ini as seed");

my @order = shuffle(0..($num_reads-1));
foreach my $file (keys %dat)
{
    open(FH, ">", $file) || die($!);
    foreach my $idx (@order)
    {
	print FH $dat{$file}[$idx];
    }
    close(FH) || die ($!);
}

diag("Written new input files");


# prepare run command
my @arg = ();
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
