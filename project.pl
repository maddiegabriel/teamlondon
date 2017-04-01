#!/usr/bin/perl 
 
#   Packages and modules  
use strict;
use warnings;
use version;   our $VERSION = qv('5.16.0');   # This is the version of Perl to be used
use Text::CSV  1.32;   # We will be using the CSV module (version 1.32 or higher)
                       # to parse each line
use Data::Dump 'dump';
use Math::Round;
use bignum;

#
#      murderRate.pl
#      Author(s): Maddie Gabriel(0927580)
#      Project: Lab Assignment 4 Task 1 Script
#      Date of Last Update: Wednesday, February 8th, 2017.
#

#   Variables to be used
my $EMPTY = q{};
my $SPACE = q{ };
my $COMMA = q{,};
my $record_count = 0;
my $csv          = Text::CSV->new({ sep_char => $COMMA });

#   Variables that I (Maddie) created and used
my $start = 0;
my $end = 0;
my $filename    = $EMPTY;
my %user_hash;
my @current_stats;
my $data;
my $crime;
my $category;

my $pop_file = "population.csv";
my @pop_data;
my $rate;
my $incidents;
my $rounded;
my $final;
my $ontario;

#set start/end year 
$start = 1998;
$end = 2005;

open my $pop_fh, '<', $pop_file
    or die "Unable to open population file: $pop_file\n";

@pop_data = <$pop_fh>;

close $pop_fh or
    die "Unable to close: $pop_file\n";

#calculate how many loops to do
while ($start <= $end) {
    
    $filename = $start."ON.csv";
    
    open my $stats_fh, '<', $filename

    >> ERROR ERROR ERROR ERROR ERROR
        or die "Unable to open names file: $filename\n";
    
    @current_stats = <$stats_fh>;

    close $stats_fh or
       die "Unable to close: $filename\n";

    foreach my $year_stats ( @current_stats ) {
        if ( $csv->parse($year_stats) ) {
            my @master_fields = $csv->fields();
            
            $crime = $master_fields[0];
            $category = $master_fields[1];

            if ( ( ($crime eq 'Murder, first degree') || ($crime eq "Murder, second degree") || ($crime eq "Manslaughter") || ($crime eq "Infanticide") ) && ($category eq 'Actual incidents') ) {
                $incidents = $master_fields[2];
                $record_count++;
                $user_hash{$record_count} = [];

                push @{$user_hash{$record_count}}, ($start,",\"",$master_fields[0],"\",", $master_fields[2]);

                foreach my $pop_stats ( @pop_data ) {
                    if ( $csv->parse($pop_stats) ) {
                        my @pop_fields = $csv->fields();
                        if ($pop_fields[1] eq $start) {
                            $ontario = sprintf("%f", $pop_fields[4]);
                            $rate = $incidents / $ontario;
                            $rounded = ($rate+0)->bstr();
                            $final =  sprintf("%.2f", $rounded * 100000);
                            push @{$user_hash{$record_count}}, (",", $final);
                        }          
                    }
                }
                $data = join "", @{$user_hash{$record_count}};
                print "$data\n";
            }
        }
    }
    $start++;
}

#   End of Script

