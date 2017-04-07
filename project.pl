#!/usr/bin/perl

#
#   CIS*2250 Project: Team London
#   Authors: Maddie Gabriel (0927580), Anthony Ciappa (), Maham Hassan (), Brandon Goldstein ()
#   Main script
#

use strict;
use version;   our $VERSION = qv('5.16.0');
use Text::CSV  1.32; # for parsing
use Statistics::R;
use Data::Dumper; # to print hashes/arrays easily 

my $COMMA = q{,};
my $csv = Text::CSV->new({ sep_char => $COMMA }); # for parsing

my ($setQ, $geo, $high_low, $violation, $year, $start_year, $end_year, $n, $general_geo) = 0;
my ($flag, $mainFlag, $exitFlag, $programFlag, $i, $graph_counter, $line_count) = 0;
my $location;
my $violation_name;
my $coordinate_location;
my $graph_filename;
my $graph_line;
my @split_values;
my @split_it;
my @data; # array stores entire file to read through
my @crime_data; # array of hashes; each hash contains the (year/coordinate/value) of a line, hash only stores .2 coordinates in array
my @result;
my @split_coord;
my %graph_hash;
my $values;
my $coords;
my $percents;
my $size;

#127 long
#line is
print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  Welcome to Team London's program!  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
print "\nPlease wait while your file loads for your usage pleasure!\n";
print "\n25 seconds remaining...\n";
# open file (real file: crime_data.csv, test file: test_data.csv)
open my $data_fh, '<', 'crime_data.csv'
    or die "Unable to open names file: \n";

@data = <$data_fh>; # store all contents of file in array 'data'

# PARSE DATA: for each line in file...
foreach my $record ( @data ) {
    # skip the first line (header line), 'next' command starts next iteration of for loop
    if ( $line_count ==  0 ) {
        $line_count++;
        next;
    }
    # parse each column of current line into $fields[n]
    # $fields[0] = year; $fields[5] = coordinate (FORMAT: location.violation.statistic); $fields[6] = value (actual rate to be compared)
    if ( $csv->parse($record) ) {
        my @fields = $csv->fields();
        # regular expression searches through each coordinate; if coordinate is of the format 'x.2', store it in hash 'data'
        # push hash containing (year/coordinate/value) into array crime_data
        if ($fields[5] =~ /\.2$/) {
            if($fields[6] ne '..') {
                my %data = (
                    year => $fields[0],
                    coordinate => $fields[5],
                    value => $fields[6]
                );
                # create a REFERENCE to the hash data (memory location), so we can push it onto the array
                # reference is: \%data, to get values we will dereference: ${$data[0]}{year}
                push @crime_data, \%data;
            } elsif ($fields[6] eq '..') {
                my %data = (
                    year => $fields[0],
                    coordinate => $fields[5],
                    value => 0
                );
                # create a REFERENCE to the hash data (memory location), so we can push it onto the array
                # reference is: \%data, to get values we will dereference: ${$data[0]}{year}
                push @crime_data, \%data;
            }
        }
    } else {
        warn "Line/record could not be parsed: $line_count.\n";
    }
    #if ($line_count % 10000 == 0) {
        #print "ON LINE: $line_count\n";     # check if reading file correctly: print every 10000th line if read correctly PRINT JOKES HERE
    #} 
    if ($line_count == 250000) {
        print "\n\n20 seconds remaining...\n";
    } elsif ($line_count == 850000) {
        print "\n\n15 seconds remaining... Half way there!\n";
    } elsif ($line_count == 1250000) {
        print "\n\n10 seconds remaining...\n";
    } elsif ($line_count == 1850000) {
        print "\n\n5 seconds remaining... Almost done!\n";
    } elsif ($line_count == 2150000) {
        print "\n\nLoading Complete!\n";
    }
    $line_count++;
}

close $data_fh;

# store geo code of all provinces (from crime_data) in provinces hash
my %provinces = (
    newfoundland => 2,
    pei => 4,
    nova_scotia => 5,
    new_brunswick => 7,
    quebec => 9,
    ontario => 16,
    manitoba => 28,
    saskatchewan => 30,
    alberta => 33,
    british_columbia => 36,
    yukon => 40,
    northwest_territories => 41,
    nunavut => 42
);
# store geo code of all cities (from crime_data) in cities hash
my %cities = (
    st_johns => 3,
    halifax => 6,
    moncton => 43,
    saint_john => 8,
    saguenay => 10,
    quebec => 11,
    sherbrooke => 12,
    trois_rivieres => 13,
    montreal => 14,
    ottawa_gatineau_quebec => 15,
    ottawa_gatineau_both => 17,
    ottawa_gatineau_ontario => 18,
    kingston => 27,
    peterborough => 44,
    toronto => 19,
    hamilton => 20,
    st_catharines_niagara => 21,
    kitchener_cambridge_waterloo => 22,
    brantford => 45,
    guelph => 46,
    london => 23,
    windsor => 24,
    barrie => 47,
    sudbury => 25,
    thunder_bay => 26,
    winnipeg => 29,
    regina => 31,
    saskatoon => 32,
    calgary => 34,
    edmonton => 35,
    kelowna => 48,
    abbotsford_mission => 39,
    vancouver => 37,
    victoria => 38
);
my %vios = (
    total_violent => 4,
    murder_first_degree=> 6,
    manslaughter => 8,
    sexual_assault_level_1 => 16,
    total_sexual_violations_against_children => 17,
    assault_level_1 => 29,
    total_firearms => 30,
    total_robbery => 34,
    total_abduction => 38,
    shoplifting => 79,
    arson => 84,
    total_prostitution => 99,
    trespass_at_night => 120,
    total_impaired_driving => 149,
    total_drug_violations => 231,
    total_criminal_code_traffic_violations => 148
);

#   user choice violations
sub print_violations {
    print "\n\n     ~~~~~~~~~~~~~~~~~~~ VIOLATION NUMBERS ~~~~~~~~~~~~~~~~~~~\n\n";
    print "     Total violent Criminal Code violations                  4\n";
    print "     Murder, First Degree                                    6\n";
    print "     Manslaughter                                            8\n";
    print "     Sexual Assault, Level 1                                16\n";
    print "     Total sexual violations against children               17\n";
    print "     Assault, Level 1                                       29\n";
    print "     Total firearms, use of, discharge, pointing            30\n"; 
    print "     Total Robbery                                          34\n";
    print "     Total Abduction                                        38\n";
    print "     Shoplifting \$5,000 or under                            79\n";
    print "     Arson                                                  84\n";
    print "     Total Prostitution                                     99\n";
    print "     Trespass at night                                     120\n";
    print "     Total Impaired Driving                                149\n";
    print "     Total Drug Violations                                 231\n";
    print "     Total Criminal Code traffic violations                148\n";
}
#   find violation string
sub violation_names {
    my ($violation) = @_;
    my $violation_name;

    if($violation == 4) {
        $violation_name = "Total violent Criminal Code violations";
    } elsif($violation == 6) {
        $violation_name = "Murder, First Degree";
    } elsif($violation == 8) {
        $violation_name = "Manslaughter";
    } elsif($violation == 16) {
        $violation_name = "Sexual Assault, Level 1";
    } elsif($violation == 17) {
        $violation_name = "Total sexual violations against children";
    } elsif($violation == 29) {
        $violation_name = "Assault, Level 1";
    } elsif($violation == 30) {
        $violation_name = "Total firearms, use of, discharge, pointing";
    } elsif($violation == 34) {
        $violation_name = "Total Robbery";
    } elsif($violation == 38) {
        $violation_name = "Total Abduction";
    } elsif($violation == 79) {
        $violation_name = "Shoplifting \$5,000 or under";
    } elsif($violation == 84) {
        $violation_name = "Arson";
    } elsif($violation == 99) {
        $violation_name = "Total Prostitution";
    } elsif($violation == 120) {
        $violation_name = "Trespass at night";
    } elsif($violation == 149) {
        $violation_name = "Total Impaired Driving ";
    } elsif($violation == 231) {
        $violation_name = "Total Drug Violations";
    } elsif($violation == 148) {
        $violation_name = "Total Criminal Code traffic violations";
    }
    return $violation_name;
}
#   user choice provinces
sub print_provinces {
    print "\n\n    ~~ LOCATION NUMBERS: PROVINCES ~~\n\n";
    print "     Alberta                         33\n";
    print "     British Columbia                36\n";
    print "     Manitoba                        28\n";
    print "     New Brunswick                    7\n";
    print "     Newfoundland and Labrador        2\n";
    print "     Nova Scotia                      5\n";
    print "     Northwest Territories           41\n";
    print "     Nunavut                         42\n";
    print "     Ontario                         16\n";
    print "     Prince Edward Island             4\n";
    print "     Quebec                           9\n";
    print "     Saskatchewan                    30\n";
    print "     Yukon                           40\n";
}
#   user choice cities
sub print_cities {
    print "\n\n     ~~~~~~ LOCATION NUMBERS: MAJOR CITIES ~~~~~~\n\n";
    print "     St. John's, Newfoundland and Labrador       3\n";
    print "     Halifax, Nova Scotia                        6\n";
    print "     Moncton, New Brunswick                     43\n";
    print "     Québec, Quebec                             11\n";
    print "     Montréal, Quebec                           14\n";
    print "     Toronto, Ontario                           19\n";
    print "     Guelph, Ontario                            46\n";
    print "     Winnipeg, Manitoba                         29\n";
    print "     Regina, Saskatchewan                       31\n";
    print "     Calgary, Alberta                           34\n";
    print "     Edmonton, Alberta                          35\n";
    print "     Vancouver, British Columbia                37\n";
    print "     Victoria, British Columbia                 38\n";
}
#   find location string
sub location_name {
    my ($coordinate_location) = @_;
    my $location;
    
    if ($coordinate_location == 41) {
        $location = "The Northwest Territories";
    } elsif ($coordinate_location == 2) {
        $location = "Newfoundland and Labrador";
    } elsif ($coordinate_location == 3) {
        $location = "St. John's, Newfoundland and Labrador";
    } elsif ($coordinate_location == 4) {
        $location = "Prince Edward Island";
    } elsif ($coordinate_location == 5) {
        $location = "Nova Scotia";
    } elsif ($coordinate_location == 6) {
        $location = "Halifax, Nova Scotia";
    } elsif ($coordinate_location == 7) {
        $location = "New Brunswick";
    } elsif ($coordinate_location == 43) {
        $location = "Moncton, New Brunswick";
    } elsif ($coordinate_location == 8) {
        $location = "Saint John, New Brunswick";
    } elsif ($coordinate_location == 9) {
        $location = "Quebec";
    } elsif ($coordinate_location == 10) {
        $location = "Saguenay, Quebec";
    } elsif ($coordinate_location == 11) {
        $location = "Québec, Quebec";
    } elsif ($coordinate_location == 12) {
        $location = "Sherbrooke, Quebec";
    } elsif ($coordinate_location == 13) {
        $location = "Trois-Rivières, Quebec";
    } elsif ($coordinate_location == 14) {
        $location = "Montréal, Quebec";
    } elsif ($coordinate_location == 15) {
        $location = "Ottawa Gatineau Quebec";
    } elsif ($coordinate_location == 16) {
        $location = "Ontario";
    } elsif ($coordinate_location == 17) {
        $location = "Ottawa Gatineau Ontario/Quebec";
    } elsif ($coordinate_location == 18) {
        $location = "Ottawa Gatineau Ontario";
    } elsif ($coordinate_location == 27) {
        $location = "Kingston, Ontario";
    } elsif ($coordinate_location == 44) {
        $location = "Peterborough, Ontario";
    } elsif ($coordinate_location == 19) {
        $location = "Toronto, Ontario";
    } elsif ($coordinate_location == 20) {
        $location = "Hamilton, Ontario";
    } elsif ($coordinate_location== 21) {
        $location = "St.Catharines-Niagara, Ontario";
    } elsif ($coordinate_location == 22) {
        $location = "Kitchener Cambridge Waterloo Ontario";
    } elsif ($coordinate_location == 45) {
        $location = "Brantford, Ontario";
    } elsif ($coordinate_location == 46) {
        $location = "Guelph, Ontario";
    } elsif ($coordinate_location == 23) {
        $location = "London, Ontario";
    } elsif ($coordinate_location == 24) {
        $location = "Windsor, Ontario";
    } elsif ($coordinate_location == 47) {
        $location = "Barrie, Ontario";
    } elsif ($coordinate_location == 25) {
        $location = "Sudbury, Ontario";
    } elsif ($coordinate_location == 26) {
        $location = "Thunder Bay, Ontario";
    } elsif ($coordinate_location == 28) {
        $location = "Manitoba";
    } elsif ($coordinate_location == 29) {
        $location = "Winnipeg, Manitoba";
    } elsif ($coordinate_location == 30) {
        $location = "Saskatchewan";
    } elsif ($coordinate_location == 31) {
        $location = "Regina, Saskatchewan";
    } elsif ($coordinate_location == 32) {
        $location = "Saskatoon, Saskatchewan";
    } elsif ($coordinate_location == 33) {
        $location = "Alberta";
    } elsif ($coordinate_location == 34) {
        $location = "Calgary, Alberta";
    } elsif ($coordinate_location == 35) {
        $location = "Edmonton, Alberta";
    } elsif ($coordinate_location == 36) {
        $location = "British Columbia";
    } elsif ($coordinate_location == 48) {
        $location = "Kelowna, British Columbia";
    } elsif ($coordinate_location == 39) {
        $location = "Abbotsford-Mission, British Columbia";
    } elsif ($coordinate_location == 37) {
        $location = "Vancouver, British Columbia";
    } elsif ($coordinate_location == 38) {
        $location = "Victoria, British Columbia";
    } elsif($coordinate_location == 40) {
        $location = "Yukon";
    } elsif ($coordinate_location == 42) {
        $location = "Nunavut";
    }
    
    return $location;
}

# QUESTION 1
sub question_one_three {
    my ($geo, $violation, $year) = @_;
    my @coordinate_keys;
    my $current_value = 0;
    my $current_location;
    my @found_records;
    my @coords;
    my @values;
    my $array_size = 0;
    my $not_complete = 0;

    if ($geo == 1) {
        for my $key (values %provinces) {
            push @coordinate_keys, "$key.$violation.2";
        }
    } else {
        for my $key (values %cities) {
            push @coordinate_keys, "$key.$violation.2";
        }
    }
    foreach my $crime_record ( @crime_data ) {
        my %record = %{$crime_record};
        if ($record{year} eq $year) {
            foreach my $coordinate_key ( @coordinate_keys ) {
                if ($record{coordinate} eq $coordinate_key) {
                    $current_value = $record{value};
                    push(@found_records, "$current_value,$coordinate_key");
                    $array_size++;
                }
            }
        }
    }
    foreach my $k (0..$array_size) {
        my @split_found = split(/\,/, $found_records[$k]);
        push(@values, $split_found[0]);
        push(@coords, $split_found[1]);
    }
    while (1 == 1) {
        $not_complete = 0;
        foreach my $j (0 .. (scalar(@values) - 2)) {
            if ($values[$j] < $values[$j + 1]) {
                my $temp_one = $values[$j + 1];
                $values[$j + 1] = $values[$j];
                $values[$j] = $temp_one;

                my $temp_two = $coords[$j + 1];
                $coords[$j + 1] = $coords[$j];
                $coords[$j] = $temp_two;
                
                $not_complete = 1;
            }
        }
        if ($not_complete == 0) {
            last;
        }
    }
    return (\@values, \@coords);
}

sub question_two_four {
    my ($geo, $violation, $start_year, $end_year) = @_;

    my @coordinate_keys;
    my $current_value = 0;
    my $array_size = 0;
    my $not_complete = 0;
    my @percents;
    my @start_values;
    my @end_values;
    my @start_coords;
    my @end_coords;

    if ($geo == 1) {
        for my $key (values %provinces) {
            push @coordinate_keys, "$key.$violation.2";
        }
    } else {
        for my $key (values %cities) {
            push @coordinate_keys, "$key.$violation.2";
        }
    }

    foreach my $crime_record ( @crime_data ) {
        my %record = %{$crime_record};

        if ($record{year} eq $start_year) {
            foreach my $coordinate_key ( @coordinate_keys ) {
                if ( ($record{coordinate} eq $coordinate_key) && exists $record{value}) {
                    $current_value = $record{value};
                    push(@start_values, $current_value);
                    push(@start_coords, $coordinate_key);
                }
            }
        }
        if ($record{year} eq $end_year) {
            foreach my $coordinate_key ( @coordinate_keys ) {
                if ( ($record{coordinate} eq $coordinate_key) && exists $record{value}) {
                    $current_value = $record{value};
                    push(@end_values, $current_value);
                    push(@end_coords, $coordinate_key);
                    $array_size++;
                }

            }
        }
    }
    #print "START VALUES :: \n\n @start_values\n\n\n";
    #print "END VALUES :: \n\n @end_values\n\n\n";  
    #print "START COORDS :: \n\n @start_coords\n\n\n";
    #print "END COORDS BEFORE :: \n\n @end_coords\n\n\n";  
    #print "\nPERCENTS BEFORE::\n";
    foreach my $m (0..$array_size) {
        if($start_coords[$m] == $end_coords[$m]) {
            $percents[$m] = ($end_values[$m] - $start_values[$m])/100;
            #print "$percents[$m] ";
        }
    }
    my $j = 0;
    while (1 == 1) {
        $not_complete = 0;
        foreach $j (0 .. (scalar(@percents) - 2)) {
            if ($percents[$j] < $percents[$j + 1]) {
                my $temp_one = $percents[$j + 1];
                $percents[$j + 1] = $percents[$j];
                $percents[$j] = $temp_one;

                my $temp_two = $end_coords[$j + 1];
                $end_coords[$j + 1] = $end_coords[$j];
                $end_coords[$j] = $temp_two;
                
                $not_complete = 1;
            }
        }
        if ($not_complete == 0) {
            last;
        }
    }
    #print "END COORDS AFTER :: \n\n @end_coords\n\n\n";  
    #print "PERCENTS AFTER ::\n\n @percents\n\n";
    # if($high_low == 1){
    #     return ($end_coords[0], $percents[0]);
    # } elsif ($high_low == 2) {
    #     return ($end_coords[$j], $percents[$j]);
    # }

    return (\@percents, \@end_coords);
}

sub question_five {
    my ($geo, $start_year, $end_year) = @_;

    my $location_name = location_name($geo);

    my $txt_filename = $location_name."_".$start_year."_".$end_year.".txt";
    my $pdf_filename = $location_name."_".$start_year."_".$end_year.".pdf";
    # print "TXT FILENAME :: $txt_filename\n";
    # print "PDF FILENAME :: $pdf_filename\n";

    open(my $fh, '>', $txt_filename) or die "Could not open file '$txt_filename'!";
    
    my @coordinate_keys;
    my $current_value;

    for my $key (values %vios) {
        push @coordinate_keys, "$geo.$key.2";
    }

    print $fh "\"Violation\",\"Year\",\"Rate\"\n";

    for my $current_year ($start_year .. $end_year) {
        foreach my $crime_record ( @crime_data ) {
            my %record = %{$crime_record};
            if ($record{year} eq $current_year) {
                foreach my $coordinate_key ( @coordinate_keys ) {
                    if ($record{coordinate} eq $coordinate_key) {
                        $current_value = $record{value};
                        $graph_hash{$graph_counter} = [];

                        @split_coord = split (/\./, $coordinate_key);
                        my $coordinate_violation = $split_coord[1];       
                        my $violation_name = violation_names($coordinate_violation);

                        push @{$graph_hash{$graph_counter}}, ("\"",$violation_name,"\",",$current_year, ",", $current_value,"\n");
                        $graph_line = join "", @{$graph_hash{$graph_counter}};

                        print $fh "$graph_line";

                        $graph_counter++;
                    }
                }
            }
        }
    }

    close $fh;

    my $R = Statistics::R->new();     # Create a communication bridge with R and start R
    $R->run(qq`pdf("$pdf_filename" , paper="letter")`);    # Set up the PDF file for plots
    $R->run(q`library(ggplot2)`);    # Load the plotting library
    $R->run(qq`data <- read.csv("$txt_filename")`);    # read in data from a CSV file
    # plot the data as a line plot with each point outlined
    $R->run(q`ggplot(data, aes(x=Year, y=Rate, colour=Violation, group=Violation)) + geom_line() + geom_point(size=2) + ggtitle("Crime Rates")`);
    $R->run(q`dev.off()`);    # close down the PDF device
    $R->stop();

    return $pdf_filename;
}

#   INTERFACE (ONCE LOADED)
print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  INSTRUCTIONS  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
print ">> Please enter the numbers corresponding to your choices.\n>> PRESS 9 FROM MAIN MENU TO EXIT.\n";

while ($programFlag == 0) {
    while ($mainFlag == 0) {
        print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  QUESTION TYPES  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; 
        print "\nQuestion Set 1: What location had the highest/lowest Rate per 100,000 Population of a violation in a year?\n\n";
        print "Question Set 2: What location had the highest/lowest percent change in the rate a violation between two years?\n\n";
        print "Question Set 3: What are the top n locations with the highest/lowest Rate per 100,000 Population of a violation in a year?\n\n";
        print "Question Set 4: What are the top n locations with the highest/lowest percent change in the rate a violation between two years?\n\n";
        print "Question Set 5: Construct a line graph for the percent change of a violation in a specific location between 2 years.\n\n\n>> PRESS 9 FROM MAIN MENU TO EXIT.\n";
        print "\n\nWould you like to pick Question Set 1, 2, 3, 4 or 5? ";
        $setQ = <STDIN>;
        chomp $setQ;
        if ($setQ == 9) {
            print "\n\nThanks for using Team London's program - See you later!\n\n";
            exit;
        } elsif ($setQ == 1 || $setQ == 2 || $setQ == 3 || $setQ == 4 || $setQ == 5) {
            $mainFlag = 1;
        }
        $flag = 0;

        # FIRST QUESTION
        if ($setQ == 1) {
            print "\nFILL IN THE BLANKS: What (province/city) had the (highest/lowest) Rate per 100,000 Population of (violation) in (year)?\n";
            while ($flag == 0) {
                print "\nProvince or city? (1 for province, 2 for city): ";
                $geo = <STDIN>;
                chomp $geo;
                if ( ($geo == 1 || $geo == 2) && $geo != '') {
                    $flag = 1;
                }
            }
            $flag = 0;
            while ($flag == 0) { 
                print "\nHighest or Lowest (1 for highest, 2 for lowest): ";
                $high_low = <STDIN>;
                chomp $high_low;
                if (($high_low == 1 || $high_low == 2) && $high_low != '') {
                    $flag = 1;
                }
            }
            $flag = 0;
            
            print_violations();
            
            while ($flag == 0){
                print "\nViolation number: ";
                $violation = <STDIN>;
                chomp $violation;
                if ($violation == 4 || $violation == 6 || $violation == 8 || $violation == 16 || $violation == 17 || $violation == 29 || $violation == 30 || $violation == 34 || $violation == 38 || $violation == 79 || $violation == 84 || $violation == 99 || $violation == 149|| $violation == 231 || $violation == 120) {
                    $flag = 1;
                }
            }
            $violation_name = violation_names($violation);
            
            $flag = 0;
            while ($flag == 0) {
                print "Year (1998 - 2015): ";
                $year = <STDIN>;
                chomp $year;
                if ($year >= 1998 && $year <= 2015) {
                    $flag = 1;
                }
            }   
            $flag = 0;

            ($values, $coords) = &question_one_three($geo, $violation, $year);
            print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ RESULT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
            if($high_low == 1) {
                @split_it = split (/\./, @$coords[0]);
                $location = location_name($split_it[0]);
                if($geo == 1) {
                   print "\n\nYOUR QUESTION: What province had the highest Rate per 100,000 Population of $violation_name in $year?\n\n";
                   print("\nThe province with the highest rate of $violation_name in $year was $location. The rate was @$values[0] per 100,000 population.\n\n");                   
                } elsif ($geo == 2) {
                   print "\n\nYOUR QUESTION: What city had the highest Rate per 100,000 Population of $violation_name in $year?\n\n";
                   print("\nThe city with the highest rate of $violation_name in $year was $location. The rate was @$values[0] per 100,000 population.\n\n");                   
                }
            } else {
                $size = scalar(@$values) - 2;
                @split_it = split (/\./, @$coords[$size]);
                $location = location_name($split_it[0]);
                if ($geo == 1) {
                   print "\n\nYOUR QUESTION: What province had the lowest Rate per 100,000 Population of $violation_name in $year?\n\n";
                   print("\nThe province with the lowest rate of $violation_name in $year was $location. The rate was @$values[$size] per 100,000 population.\n\n");                   
                } elsif ($geo == 2) {
                   print "\n\nYOUR QUESTION: What city had the lowest Rate per 100,000 Population of $violation_name in $year?\n\n";
                   print("\nThe city with the lowest rate of $violation_name in $year was $location. The rate was @$values[$size] per 100,000 population.\n\n");                   
                }
            }
           print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NEXT QUESTION ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n"; 
        #   SECOND QUESTION
        } elsif ($setQ == 2) {
               print "\nFILL IN THE BLANKS: What (province/city) had the (highest/lowest) percent change in (violation) from (year) to (year)?\n";
               
               while ($flag == 0) {
                   print "\nProvince or city? (1 for province, 2 for city): ";
                   $geo = <STDIN>;
                   chomp $geo ;
                   if (($geo  == 1 || $geo  == 2) && $geo  != '') {
                       $flag = 1;
                   }
               }
               $flag = 0;
               while ($flag == 0) {
                   print "\nHighest or Lowest (1 for highest, 2 for lowest): ";
                   $high_low = <STDIN>;
                   chomp $high_low;
                   if (($high_low == 1 || $high_low == 2) && $high_low != '') {
                       $flag = 1;
                   }
               }
               $flag = 0;
               
               print_violations();

               while ($flag == 0){    
                   print "\nViolation number: ";
                   $violation = <STDIN>;
                   chomp $violation;
                   if ($violation == 4 || $violation == 6 || $violation == 8 || $violation == 16 || $violation == 17 || $violation == 29 || $violation == 30 || $violation == 34 || $violation == 38 || $violation == 79 || $violation == 84 || $violation == 99 || $violation == 149|| $violation == 231 || $violation == 120) {
                       $flag = 1;
                   }
               }
               my $violation_name = violation_names($violation);
               $flag = 0;
               
               while ($flag == 0) {
                   print "Start year (1998 - 2015): ";
                   $start_year = <STDIN>;
                   chomp $start_year;
                   if ($start_year >= 1998 && $start_year <= 2015) {
                       $flag = 1;
                   }
               }
               $flag = 0;
               
               while ($flag == 0) {
                   print "End year (1998 - 2015): ";
                   $end_year = <STDIN>;
                   chomp $end_year;
                   if ($end_year >= 1998 && $end_year <= 2015 && $end_year > $start_year) {
                       $flag = 1;
                   }
               }
               $flag = 0;

                ($percents, $coords) = &question_two_four(int($geo), int($violation), int($start_year), int($end_year));

                print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ RESULT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
                if($high_low == 1) {
                    @split_it = split (/\./, @$coords[0]);
                    $location = location_name($split_it[0]);
                    if($geo == 1) {
                       print("\nThe province with the highest percent change of $violation_name between $start_year and $end_year was $location. The percent change was @$percents[0]%.\n");                   
                    } elsif ($geo == 2) {
                       print("\nThe city with the highest percent change of $violation_name between $start_year and $end_year was $location. The percent change was @$percents[0]%.\n");                   
                    }
                } else {
                    $size = scalar(@$percents) - 2;
                    @split_it = split (/\./, @$coords[$size]);
                    $location = location_name($split_it[0]);
                    if ($geo == 1) {
                       print("\nThe province with the lowest percent change of $violation_name between $start_year and $end_year was $location. The percent change was @$percents[$size]%.\n");                   
                    } elsif ($geo == 2) {
                       print("\nThe city with the lowest percent change of $violation_name between $start_year and $end_year was $location. The percent change was @$percents[$size]%.\n");                   
                    }
                }
               print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NEXT QUESTION ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"; 
        #  THIRD QUESTION
       } elsif ($setQ == 3) {
           print "\nFILL IN THE BLANKS: What (provinces/cities) had the (top/bottom) (n) rate of (violation) in (year)?\n";
           while ($flag == 0) {
               print "\nProvince or city? (1 for province, 2 for city): ";
               $geo = <STDIN>;
               chomp $geo;
               if ( ($geo == 1 || $geo == 2) && $geo != '') {
                   $flag = 1;
               }
           }
           $flag = 0;
           while ($flag == 0) { 
               print "\nTop or Bottom (1 for top, 2 for bottom): ";
               $high_low = <STDIN>;
               chomp $high_low;
               if (($high_low == 1 || $high_low == 2) && $high_low != '') {
                   $flag = 1;
               }
           }
           $flag = 0;
           while ($flag == 0) { 
               print "\nn = ? ";
               $n = <STDIN>;
               chomp $n;
               if ($n > 0 && $n != '') {
                    if( $geo == 1 && $n <= 13) {
                       $flag = 1;
                   } elsif ($geo == 2 && $n <= 34 ) {
                        $flag = 1;
                   }
                
               }
           }
           $flag = 0;
           
           print_violations();
           
           while ($flag == 0){
               print "\nViolation number: ";
               $violation = <STDIN>;
               chomp $violation;
               if ($violation == 4 || $violation == 6 || $violation == 8 || $violation == 16 || $violation == 17 || $violation == 29 || $violation == 30 || $violation == 34 || $violation == 38 || $violation == 79 || $violation == 84 || $violation == 99 || $violation == 149|| $violation == 231 || $violation == 120) {
                   $flag = 1;
               }
           }
           $violation_name = violation_names($violation);
 
           $flag = 0;
           while ($flag == 0) {
               print "Year (1998 - 2015): ";
               $year = <STDIN>;
               chomp $year;
               if ($year >= 1998 && $year <= 2015) {
                   $flag = 1;
               }
           }   
           $flag = 0;


           ($values, $coords) = &question_one_three($geo, $violation, $year);

           print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ RESULT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
           if($high_low == 1) {
                if($geo == 1) {
                   print("\nThe top $n provinces with the highest rates of $violation_name in $year are:\n");
                   for($i = 0; $i < $n; $i++) {
                       @split_it = split (/\./, @$coords[$i]);
                       my $location = location_name($split_it[0]);
                       print("\n",$i+1,".   $location: @$values[$i] per 100,000 population.");
                   } 
                } elsif ($geo == 2) {
                    print("\nThe top $n cities with the highest rates of $violation_name in $year are:\n");
                   for($i = 1; $i <= $n; $i++) {
                       @split_it = split (/\./, @$coords[$i]);
                       my $location = location_name($split_it[0]);
                       print("\n",$i+1,".   $location: @$values[$i] per 100,000 population.");
                   } 
                }
           } else {
                my $size = scalar(@$values) - 2;
                if($geo == 1) {
                   print("\nThe bottom $n provinces with the lowest rates of $violation_name in $year are:\n");
                   for($i = ($size - $n + 1); $i <= $size; $i++) {
                       @split_it = split (/\./, @$coords[$i]);
                       my $location = location_name($split_it[0]);
                       print("\n",$i+1,".   $location: @$values[$i] per 100,000 population.");
                   }
                } elsif ($geo == 2) {
                   print("\nThe bottom $n cities with the lowest rates of $violation_name in $year are:\n");
                   for($i = ($size - $n + 1); $i <= $size; $i++) {
                       @split_it = split (/\./, @$coords[$i]);
                       my $location = location_name($split_it[0]);
                       print("\n",$i+1,".   $location: @$values[$i] per 100,000 population.");
                   }
                }
           }
           print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NEXT QUESTION ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
       } elsif ($setQ == 4) {
           print "\nFILL IN THE BLANKS: What (provinces/cities) had the (top/bottom) (n) percent change of (violation) from (start year) to (end year)?\n";
           while ($flag == 0) {
               print "\nProvinces or cities? (1 for province, 2 for city): ";
               $geo = <STDIN>;
               chomp $geo;
               if ( ($geo == 1 || $geo == 2) && $geo != '') {
                   $flag = 1;
               }
           }
           $flag = 0;
           while ($flag == 0) {
               print "\nTop or Bottom (1 for top, 2 for bottom): ";
               $high_low = <STDIN>;
               chomp $high_low;
               if (($high_low == 1 || $high_low == 2) && $high_low != '') {
                   $flag = 1;
               }
           }
            $flag = 0;
           while ($flag == 0) { 
               print "\nn = ? ";
               $n = <STDIN>;
               chomp $n;
               if ($n > 0 && $n != '') {
                    if( $geo == 1 && $n <= 13) {
                       $flag = 1;
                   } elsif ($geo == 2 && $n <= 34 ) {
                        $flag = 1;
                   }
                
               }
           }
           $flag = 0;

           print_violations();
           
           while ($flag == 0){
               print "\nViolation number: ";
               $violation = <STDIN>;
               chomp $violation;
               if ($violation == 4 || $violation == 6 || $violation == 8 || $violation == 16 || $violation == 17 || $violation == 29 || $violation == 30 || $violation == 34 || $violation == 38 || $violation == 79 || $violation == 84 || $violation == 99 || $violation == 149|| $violation == 231 || $violation == 120) {
                   $flag = 1;
               }
           }

           $violation_name = violation_names($violation);

           $flag = 0;
           while ($flag == 0) {
               print "Start year (1998 - 2015): ";
               $start_year = <STDIN>;
               chomp $start_year;
               if ($start_year >= 1998 && $start_year <= 2015) {
                   $flag = 1;
               }
           }
           $flag = 0;
           
           while ($flag == 0) {
               print "End year (1998 - 2015): ";
               $end_year = <STDIN>;
               chomp $end_year;
               if ($end_year >= 1998 && $end_year <= 2015 && $end_year > $start_year) {
                   $flag = 1;
               }
           }
           $flag = 0;

           ($percents, $coords) = &question_two_four($geo, $violation, $start_year, $end_year);
           #print "QQQQ24 :: \n\n\n";
           #print question_two_four($geo, $violation, $start_year, $end_year);
           print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ RESULT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
           if($high_low == 1) {
                if($geo == 1) {
                   print("\nThe top $n provinces with the highest rates of $violation_name from $start_year to $end_year were:\n");
                   for($i = 0; $i < $n; $i++) {
                       @split_it = split (/\./, @$coords[$i]);
                       my $location = location_name($split_it[0]);
                       print("\n",$i+1,".   $location: @$percents[$i]%.");
                   } 
                } elsif ($geo == 2) {
                    print("\nThe top $n cities with the highest rates of $violation_name from $start_year to $end_year were:\n");
                   for($i = 1; $i <= $n; $i++) {
                       @split_it = split (/\./, @$coords[$i]);
                       my $location = location_name($split_it[0]);
                       print("\n",$i+1,".   $location: @$percents[$i]%.");
                   } 
                }
           } else {
                my $size = scalar(@$percents) - 2;
                if($geo == 1) {
                   print("\nThe bottom $n provinces with the lowest rates of $violation_name from $start_year to $end_year were:\n");
                   for($i = ($size - $n + 1); $i <= $size; $i++) {
                       @split_it = split (/\./, @$coords[$i]);
                       my $location = location_name($split_it[0]);
                       print("\n",$i+1,".   $location: @$percents[$i]%.");
                   }
                } elsif ($geo == 2) {
                   print("\nThe bottom $n cities with the lowest rates of $violation_name from $start_year to $end_year were\n");
                   for($i = ($size - $n + 1); $i <= $size; $i++) {
                       @split_it = split (/\./, @$coords[$i]);
                       my $location = location_name($split_it[0]);
                       print("\n",$i+1,".   $location: @$percents[$i]%.");
                   }
                }
           }
           print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NEXT QUESTION ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
       } elsif ($setQ == 5) {
           print "\nFILL IN THE BLANKS: Give me the line graph showing the trend of our 12 violations in (location) between (start year) and (end year).\n";
           while ($flag == 0) {
               print "\nProvince or city? (1 for province, 2 for city): ";
               $general_geo = <STDIN>;
               chomp $general_geo;
               if (($general_geo  == 1 || $general_geo == 2) && $general_geo != '') {
                   $flag = 1;
               }
               if($general_geo == 1) {
                    print_provinces();
               } elsif($general_geo = 2) {
                    print_cities();
               }
           }
           $flag = 0;
            while ($flag == 0) {
               print "\nLocation number: ";
               $geo = <STDIN>;
               chomp $geo;
               if ( $geo != '') {
                    if( $general_geo == 1 && ($geo == 33 || $geo == 36 || $geo == 28 || $geo == 7 || $geo == 2 || $geo == 5 || $geo == 41 || $geo == 42 || $geo == 16 || $geo == 4 || $geo == 9 || $geo == 30 || $geo == 40)) {
                        $flag = 1;
                    } elsif ($general_geo == 2 && ($geo == 3 || $geo == 6 || $geo == 43 || $geo == 11 || $geo == 14 || $geo == 19 || $geo == 46 || $geo == 29 || $geo == 31 || $geo == 34 || $geo == 35 || $geo == 37 || $geo == 38)) {
                        $flag = 1;
                    } 
               }
           }
           $flag = 0;
           while ($flag == 0) {
               print "Start year (1998 - 2015): ";
               $start_year = <STDIN>;
               chomp $start_year;
               if ($start_year >= 1998 && $start_year <= 2015) {
                   $flag = 1;
               }
           }
           $flag = 0;
           while ($flag == 0) {
               print "End year (1998 - 2015): ";
               $end_year = <STDIN>;
               chomp $end_year;
               if ($end_year >= 1998 && $end_year <= 2015 && $end_year > $start_year) {
                   $flag = 1;
               }
           }
           $flag = 0;

           $graph_filename = question_five($geo, $start_year, $end_year);
           print "\n\nYour graph has been created! \nOpen this pdf file to view it :: $graph_filename\n\n";
       }
        $mainFlag = 0;
    }
}
