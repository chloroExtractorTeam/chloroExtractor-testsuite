#!/usr/bin/env perl

use strict;
use warnings;
use File::Temp;
use Archive::Extract;
use Digest::MD5;
use List::Util qw(shuffle);

use Test::More;
use Test::Script::Run;

my %files = (
    'divide_by_zero_bug_testset_1.fq' => "25fc173d905fddab13aa16fa34d6fdf3",
    'divide_by_zero_bug_testset_2.fq' => "03b1e21629ca926ba547153e2918cf88"
    );

my $location = "divide_by_zero_bug_testset.tar.gz";
my $tempdir = File::Temp::tempdir();

my $ae = Archive::Extract->new( archive => $location );

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

	push(@{$dat{$file}}, "".$s."+\n".$q);
    }
    close(FH) || die ($!);

    if ($num_reads == 0)
    {
	$num_reads = scalar @{$dat{$file}};
    } else {
	die "Different number of reads" if ($num_reads != scalar @{$dat{$file}});
    }
}

# we need 10x the read set
foreach my $file (keys %dat)
{
    my @tmp = @{$dat{$file}};
    $dat{$file} = [@tmp, @tmp, @tmp, @tmp, @tmp, @tmp, @tmp, @tmp, @tmp, @tmp];
    $num_reads = int(@{$dat{$file}});
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
	print FH "\@seq.$idx\n".$dat{$file}[$idx];
    }
    close(FH) || die ($!);
}

diag("Written new input files");

# run jellyfish
my @cmd = ("jellyfish");
my @arg = qw(count -m 31 -s 500M -C -o jf0.jf);
push(@arg, @filenames);

push(@cmd, @arg);

my $stdout = qx(@cmd);
my $error_code = $?;

is($error_code, 0, 'Run of jellyfish returns 0 as error code');

# prepare scale_reads.pl command
@cmd = ("bin/scale_reads.pl");
@arg = qw(--ref-cluster data/cds-nr98-core.fa --kmer-size 31 --out scr -c ptx.cfg);
for(my $i = 1; $i <= @filenames; $i++)
{
    push(@arg, ("-".$i, $filenames[$i-1]));
}

push(@cmd, @arg);

$stdout = qx(@cmd);
$error_code = $?;

is($error_code, 0, 'Run of scale_reads.pl returns 0 as error code');

done_testing;
