#!/usr/bin/perl

#
#   CIS*2250 Project: Team London
#   Main script
#

use strict;
use version;   our $VERSION = qv('5.16.0');
use Text::CSV  1.32; # for parsing

my $EMPTY = q{};
my $SPACE = q{ };
my $COMMA = q{,};
my ($setQ, $geo_q1, $high_low_q1, $violation_q1, $year_q1) = 0;
my ($geo_q2, $high_low_q2, $violation_q2, $start_year, $end_year) = 0;
my ($high_low_q3, $n, $geo_q3, $violation_q3, $year_q3) = 0;
my ($flag, $mainFlag, $exitFlag, $programFlag) = 0;
my $location;
my @split_values;
use Data::Dumper; # to print hashes/arrays easily 

my @data; # array stores entire file to read through
my $csv = Text::CSV->new({ sep_char => $COMMA }); # for parsing
my @crime_data; # array of hashes; each hash contains the (year/coordinate/value) of a line, hash only stores .2 coordinates in array
my $line_count = 0;
my @result_q1;
my $violation_name;
my $i;

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
            }
        }
    } else {
        warn "Line/record could not be parsed: $line_count.\n";
    }
    
    if ($line_count % 10000 == 0) {
        print "ON LINE: $line_count\n";     # check if reading file correctly: print every 10000th line if read correctly PRINT JOKES HERE
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

# QUESTION 1: function aggregates required data (from user input) and finds highest / lowest value
sub question_one {
    # From user input: year, violation #, 0 (city) or 1 (province), 0 (low) or 1 (high)
    my ($year_q1, $violation_q1, $geo_q1, $high_low) = @_;

    # Build an array of possible crime_data values using: ('provinces' or 'cities' hash value) + (the violation number) + '.2'
    my @coordinate_keys;
    my $current_value;
    my $current_location;

    # if entered 1 for province, go through provinces hash. create array of desired coordinates using province.violation.2 
    if ($geo_q1 == 1) {
        for my $key (values %provinces) {
            push @coordinate_keys, "$key.$violation_q1.2";
        }
    # if entered 2 for city, go through cities hash. create array of desired coordinates using city.violation.2 
    } else {
        for my $key (values %cities) {
            push @coordinate_keys, "$key.$violation_q1.2";
        }
    }

    # go through crime_data array (has crime hashes containing year, coordinate, value)
    foreach my $crime_record ( @crime_data ) {
        my %record = %{$crime_record};        #make a new hash for each year/coordinate/value in crime data array

        # if year in current hash = year given by user
        if ($record{year} eq $year_q1) {
            # sort thorugh coordinates we created using (province/city).violation.2
            foreach my $coordinate_key ( @coordinate_keys ) {
                # if coordinate in current hash = coordinate we created 
                if ($record{coordinate} eq $coordinate_key) {
                    # print Dumper(\%record);

                    # SORT VALUES!!! if not first loop..
                    if ($current_value) {
                        # if user wants highest value, and value in hash is greater than current highest value
                        # set current_value to the record value
                        if ($high_low_q1== 1 and $record{value} > $current_value) {
                            $current_value = $record{value}; 
                            $current_location = $coordinate_key;
                        }
                        # if user wants lower value, and value in hash is lesser than current lowest value
                        # set current_value to the record value
                        if ($high_low_q1== 2 and $record{value} < $current_value) {
                            $current_value = $record{value}; 
                            $current_location = $coordinate_key; 
                        }
                    # if first loop: set value in hash equal to current_value
                    } else {
                        $current_value = $record{value};   
                        $current_location = $coordinate_key;    
                    }
                }
            }
        }
    }
    # if no value is found (current_value never defined), print error
    unless (defined $current_value) {
        $current_value = "Value not found.\n";
    }

    #return $current_value;????
    #return location coordinate
    return ($current_location, $current_value);
}

#
#   INTERFACE
#
print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  Welcome to Team London's program!  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
print "\nINSTRUCTIONS:\n >> Please enter the numbers corresponding to your choices.\n >> PRESS 9 TO EXIT.\n";

while ($programFlag == 0) {
    while ($mainFlag == 0) {
        
        print "\nQUESTION TYPES:"; 
        print "\nQuestion Set 1: What location had the highest/lowest rate of a specific violation in a specific year?\n";
        print "\nQuestion Set 2: What location had the highest/lowest percent change in a specific violation between two years?\n";
        print "\nQuestion Set 3: What was the safest/least safe place to do different things in Canada in a specific year?\n";
        
        print "\n\nWould you like to pick Question Set 1, 2 or 3? ";
        $setQ = <STDIN>;
        chomp $setQ;

        if ($setQ == 9) {
            exit;
        } elsif ($setQ == 1 || $setQ == 2 || $setQ == 3) {
            $mainFlag = 1;
        }
        $flag = 0;

        #
        # FIRST QUESTION
        #
        if ($setQ == 1) {
            print "\nFILL IN THE BLANKS:\nWhat (province/city) had the (highest/lowest) rate of (violation) in (year)?\n";
            while ($flag == 0) {
                print "\nProvince or city? (1 for province, 2 for city): ";
                $geo_q1 = <STDIN>;
                chomp $geo_q1;
                if ( ($geo_q1 == 1 || $geo_q1 == 2) && $geo_q1!= '') {
                    $flag = 1;
                }
            }
            $flag = 0;
            while ($flag == 0) { 
                print "\nHighest or Lowest (1 for highest, 2 for lowest): ";
                $high_low_q1= <STDIN>;
                chomp $high_low_q1;
                if (($high_low_q1== 1 || $high_low_q1== 2) && $high_low_q1!= '') {
                    $flag = 1;
                }
            }
            $flag = 0;
            print "\n\n     ~~~~~~~~~~~~~~~~~~~ VIOLATION NUMBERS ~~~~~~~~~~~~~~~~~~~\n\n";
            print "     Abduction under the age 14, not parent or guardian     39\n";
            print "     Arson                                                  84\n";
            print "     Dangerous vehicle operation, causing death            161\n";
            print "     Luring a child                                         21\n";
            print "     Participate in activity of terrorist group            128\n";
            print "     Total breaking and entering                            65\n";
            print "     Total Criminal Code traffic violations                148\n";
            print "     Total Impaired Driving                                149\n";
            print "     Total robbery                                          34\n";
            print "     Total violent Criminal Code violations                  4\n";
            print "     Shoplifting \$5,000 or under                            79\n";
            print "     Total sexual violations against children               17\n";   
            while ($flag == 0){
                print "\nViolation number: ";
                $violation_q1 = <STDIN>;
                chomp $violation_q1;
                if ($violation_q1 == 39 || $violation_q1 == 84 || $violation_q1 == 161 || $violation_q1 == 21 || $violation_q1 == 128 || $violation_q1 == 65 || $violation_q1 == 148 || $violation_q1 == 149 || $violation_q1 == 34 || $violation_q1 == 4 || $violation_q1 == 79 || $violation_q1 == 17) {
                    $flag = 1;
                }
            }
            #violation names
            if($violation_q1 == 39) {
                $violation_name = "Abduction under the age 14, not parent or guardian";
                } elsif($violation_q1 == 84) {
                    $violation_name = "Arson";
                } elsif($violation_q1 == 161) {
                    $violation_name = "Dangerous vehicle operation, causing death";
                } elsif($violation_q1 == 21) {
                    $violation_name = "Luring a child";
                } elsif($violation_q1 == 128) {
                    $violation_name = "Participate in activity of terrorist group";
                } elsif($violation_q1 == 65) {
                    $violation_name = "Total breaking and entering";
                } elsif($violation_q1 == 148) {
                    $violation_name = "Total Criminal Code traffic violations";
                } elsif($violation_q1 == 149) {
                    $violation_name = "Total Impaired Driving";
                } elsif($violation_q1 == 34) {
                    $violation_name = "Total robbery ";
                } elsif($violation_q1 == 4) {
                    $violation_name = "Total violent Criminal Code violations";
                } elsif($violation_q1 == 79) {
                    $violation_name = "Shoplifting \$5,000 or under";
                } elsif($violation_q1 == 17) {
                    $violation_name = "Total sexual violations against children ";
            }

            $flag = 0;
            while ($flag == 0) {
                print "Year (1998 - 2015): ";
                $year_q1 = <STDIN>;
                chomp $year_q1;
                if ($year_q1 >= 1998 && $year_q1 <= 2015) {
                    $flag = 1;
                }
            }   
            $flag = 0;

            # call function that finds what the user wants; it returns the coordinate of the place with the highest/lowest value of the violation, as well as the value itself.
            #print question_one($year_q1, $violation_q1, $geo_q1, $high_low_q1); 
            @result_q1 = question_one($year_q1, $violation_q1, $geo_q1, $high_low_q1);
            #print "RESULT ARRAY:: @result_q1";     #print "result_q1[0] :: $result_q1[0]\n"; #print "result_q1[1] :: $result_q1[1]\n";
            
            # String split coordinate by period - this makes each number of the coordinate an element in the array @split_values
            @split_values = split (/\./, $result_q1[0]);
            # extract location number from coordinate (first element of split_values array) - it corresponds to a location string; this is for printing nicely
            #print "$split_num[0]"; #print "$split_values[0]";
            if ($split_values[0] == 41) {
                $location = "The Northwest Territories";  
                } elsif ($split_values[0] == 2) {
                $location = "Newfoundland and Labrador";
                } elsif ($split_values[0] == 3) {
                    $location = "St. John's, Newfoundland and Labrador";
                } elsif ($split_values[0] == 4) {
                    $location = "Prince Edward Island";
                } elsif ($split_values[0] == 5) {
                    $location = "Nova Scotia";
                } elsif ($split_values[0] == 6) {
                    $location = "Halifax, Nova Scotia";
                } elsif ($split_values[0] == 7) {
                    $location = "New Brunswick";
                } elsif ($split_values[0] == 43) {
                    $location = "Moncton, New Brunswick";
                } elsif ($split_values[0] == 8) {
                    $location = "Saint John, New Brunswick";
                } elsif ($split_values[0] == 9) {
                    $location = "Quebec";
                } elsif ($split_values[0] == 10) {
                    $location = "Saguenay, Quebec";
                } elsif ($split_values[0] == 11) {
                    $location = "Québec, Quebec";
                } elsif ($split_values[0] == 12) {
                    $location = "Sherbrooke, Quebec";
                } elsif ($split_values[0] == 13) {
                    $location = "Trois-Rivières, Quebec";
                } elsif ($split_values[0] == 14) {
                    $location = "Montréal, Quebec";
                } elsif ($split_values[0] == 15) {
                    $location = "Ottawa Gatineau Quebec";
                } elsif ($split_values[0] == 16) {
                    $location = "Ontario";
                } elsif ($split_values[0] == 17) {
                    $location = "Ottawa Gatineau Ontario/Quebec";
                } elsif ($split_values[0] == 18) {
                    $location = "Ottawa Gatineau Ontario";
                } elsif ($split_values[0] == 27) {
                    $location = "Kingston, Ontario";
                } elsif ($split_values[0] == 44) {
                    $location = "Peterborough, Ontario";
                } elsif ($split_values[0] == 19) {
                    $location = "Toronto, Ontario";
                } elsif ($split_values[0] == 20) {
                    $location = "Hamilton, Ontario";
                } elsif ($split_values[0] == 21) {
                    $location = "St.Catharines-Niagara, Ontario";
                } elsif ($split_values[0] == 22) {
                    $location = "Kitchener Cambridge Waterloo Ontario";
                } elsif ($split_values[0] == 45) {
                    $location = "Brantford, Ontario";
                } elsif ($split_values[0] == 46) {
                    $location = "Guelph, Ontario";
                } elsif ($split_values[0] == 23) {
                    $location = "London, Ontario";
                } elsif ($split_values[0] == 24) {
                    $location = "Windsor, Ontario";
                } elsif ($split_values[0] == 47) {
                    $location = "Barrie, Ontario";
                } elsif ($split_values[0] == 25) {
                    $location = "Sudbury, Ontario";
                } elsif ($split_values[0] == 26) {
                    $location = "Thunder Bay, Ontario";
                } elsif ($split_values[0] == 28) {
                    $location = "Manitoba";
                } elsif ($split_values[0] == 29) {
                    $location = "Winnipeg, Manitoba";
                } elsif ($split_values[0] == 30) {
                    $location = "Saskatchewan";
                } elsif ($split_values[0] == 31) {
                    $location = "Regina, Saskatchewan";
                } elsif ($split_values[0] == 32) {
                    $location = "Saskatoon, Saskatchewan";
                } elsif ($split_values[0] == 33) {
                    $location = "Alberta";
                } elsif ($split_values[0] == 34) {
                    $location = "Calgary, Alberta";
                } elsif ($split_values[0] == 35) {
                    $location = "Edmonton, Alberta";
                } elsif ($split_values[0] == 36) {
                    $location = "British Columbia";
                } elsif ($split_values[0] == 48) {
                    $location = "Kelowna, British Columbia";
                } elsif ($split_values[0] == 39) {
                    $location = "Abbotsford-Mission, British Columbia";
                } elsif ($split_values[0] == 37) {
                    $location = "Vancouver, British Columbia";
                } elsif ($split_values[0] == 38) {
                    $location = "Victoria, British Columbia";
                } elsif($split_values[0] == 40) {
                    $location = "Yukon";
                } elsif ($split_values[0] == 42) {
                    $location = "Nunavut";
            }

            # RETURN OUTPUT
            print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ RESULT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
            #print aggregate_data($year_q1, $violation_q1_number, $geo_q1, $high_low);
            #print "\ncoordinate: $result_coordinate\n"; #print "location: $location\n";
            if($high_low_q1== 1) {
                print("\nThe highest rate of $violation_name in $year_q1 was $result_q1[1] per 100,000 population. It occured in $location.\n");
            } else {
                print("\nThe lowest rate of $violation_name in $year_q1 was $result_q1[1] per 100,000 population. It occured in $location.\n");
            }
            print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SEE YA! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
        
        #   SECOND QUESTION
        } elsif ($setQ == 2) {
            print "\nFILL IN THE BLANKS:\nWhat (province/city) had the (highest/lowest) percent change in (violation) from (year) to (year)?\n";
            
            while ($flag == 0) {
                print "\nProvince or city? (1 for province, 2 for city): ";
                $geo_q2 = <STDIN>;
                chomp $geo_q2 ;
                if (($geo_q2  == 1 || $geo_q2  == 2) && $geo_q2  != '') {
                    $flag = 1;
                }
            }
            $flag = 0;
            while ($flag == 0) {
                print "\nHighest or Lowest (1 for highest, 2 for lowest): ";
                $high_low_q2 = <STDIN>;
                chomp $high_low_q2;
                if (($high_low_q2 == 1 || $high_low_q2 == 2) && $high_low_q2 != '') {
                    $flag = 1;
                }
            }
            $flag = 0;
            print "\n\n     ~~~~~~~~~~~~~~~~~~~ VIOLATION NUMBERS ~~~~~~~~~~~~~~~~~~~\n\n";
            print "     Abduction under the age 14, not parent or guardian     39\n";
            print "     Arson                                                  84\n";
            print "     Dangerous vehicle operation, causing death            161\n";
            print "     Luring a child                                         21\n";
            print "     Participate in activity of terrorist group            128\n";
            print "     Total breaking and entering                            65\n";
            print "     Total Criminal Code traffic violations                148\n";
            print "     Total Impaired Driving                                149\n";
            print "     Total robbery                                          34\n";
            print "     Total violent Criminal Code violations                  4\n";
            print "     Shoplifting \$5,000 or under                            79\n";
            print "     Total sexual violations against children               17\n";
                
            while ($flag == 0){    
                print "\nViolation number: ";
                $violation_q2 = <STDIN>;
                chomp $violation_q2;
                if ($violation_q2 == 39 || $violation_q2 == 84 || $violation_q2 == 161 || $violation_q2 == 21 || $violation_q2 == 128 || $violation_q2 == 65 || $violation_q2 == 148 || $violation_q2 == 149 || $violation_q2 == 34 || $violation_q2 == 4 || $violation_q2 == 79 || $violation_q2 == 17) {
                    $flag = 1;
                }
            }
            $flag = 0;
            
            while ($flag == 0) {
                print "Start year (1998 - 2015): ";
                $start_year = <STDIN>;
                if ($start_year >= 1998 && $start_year <= 2015) {
                    $flag = 1;
                }
            }
            $flag = 0;
            
            while ($flag == 0) {
                print "End year (1998 - 2015): ";
                $end_year = <STDIN>;
                if ($end_year >= 1998 && $end_year <= 2015 && $end_year > $start_year) {
                    $flag = 1;
                }
            }
            $flag = 0;

        } elsif ($setQ == 3) {
            print "\nFILL IN THE BLANKS:\nWhat (provinces/cities) had the (top/bottom) (n) rate of (violation) in (year)?\n";
            while ($flag == 0) {
                print "\nProvince or city? (1 for province, 2 for city): ";
                $geo_q3 = <STDIN>;
                chomp $geo_q3;
                if ( ($geo_q3 == 1 || $geo_q3 == 2) && $geo_q3!= '') {
                    $flag = 1;
                }
            }
            $flag = 0;
            while ($flag == 0) { 
                print "\nTop or Bottom (1 for top, 2 for bottom): ";
                $high_low_q3 = <STDIN>;
                chomp $high_low_q3;
                if (($high_low_q3== 1 || $high_low_q3 == 2) && $high_low_q3 != '') {
                    $flag = 1;
                }
            }
            $flag = 0;
            while ($flag == 0) { 
                print "\nn = ? ";
                $n = <STDIN>;
                chomp $n;
                if ($n > 0 && $n != '') {
                    $flag = 1;
                }
            }
            $flag = 0;
            print "\n\n     ~~~~~~~~~~~~~~~~~~~ VIOLATION NUMBERS ~~~~~~~~~~~~~~~~~~~\n\n";
            print "     Abduction under the age 14, not parent or guardian     39\n";
            print "     Arson                                                  84\n";
            print "     Dangerous vehicle operation, causing death            161\n";
            print "     Luring a child                                         21\n";
            print "     Participate in activity of terrorist group            128\n";
            print "     Total breaking and entering                            65\n";
            print "     Total Criminal Code traffic violations                148\n";
            print "     Total Impaired Driving                                149\n";
            print "     Total robbery                                          34\n";
            print "     Total violent Criminal Code violations                  4\n";
            print "     Shoplifting \$5,000 or under                            79\n";
            print "     Total sexual violations against children               17\n";   
            while ($flag == 0){
                print "\nViolation number: ";
                $violation_q3 = <STDIN>;
                chomp $violation_q3;
                if ($violation_q3 == 39 || $violation_q3 == 84 || $violation_q3 == 161 || $violation_q3 == 21 || $violation_q3 == 128 || $violation_q3 == 65 || $violation_q3 == 148 || $violation_q3 == 149 || $violation_q3 == 34 || $violation_q3 == 4 || $violation_q3 == 79 || $violation_q3 == 17) {
                    $flag = 1;
                }
            }
            #violation names
            if($violation_q3 == 39) {
                $violation_name = "Abduction under the age 14, not parent or guardian";
                } elsif($violation_q3 == 84) {
                    $violation_name = "Arson";
                } elsif($violation_q3 == 161) {
                    $violation_name = "Dangerous vehicle operation, causing death";
                } elsif($violation_q3 == 21) {
                    $violation_name = "Luring a child";
                } elsif($violation_q3 == 128) {
                    $violation_name = "Participate in activity of terrorist group";
                } elsif($violation_q3 == 65) {
                    $violation_name = "Total breaking and entering";
                } elsif($violation_q3 == 148) {
                    $violation_name = "Total Criminal Code traffic violations";
                } elsif($violation_q3 == 149) {
                    $violation_name = "Total Impaired Driving";
                } elsif($violation_q3 == 34) {
                    $violation_name = "Total robbery ";
                } elsif($violation_q3 == 4) {
                    $violation_name = "Total violent Criminal Code violations";
                } elsif($violation_q3 == 79) {
                    $violation_name = "Shoplifting \$5,000 or under";
                } elsif($violation_q3 == 17) {
                    $violation_name = "Total sexual violations against children ";
            }

            $flag = 0;
            while ($flag == 0) {
                print "Year (1998 - 2015): ";
                $year_q3 = <STDIN>;
                chomp $year_q3;
                if ($year_q3 >= 1998 && $year_q3 <= 2015) {
                    $flag = 1;
                }
            }   
            $flag = 0;

            # call function that finds what the user wants
            # RETURN OUTPUT
            print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ RESULT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
            if($high_low_q3== 1) {
                print("\nThe top $n (provinces/cities) with the highest rates of $violation_name in $year_q1 are:\n");
                for($i = 1; $i <= $n; $i++) {
                    print("\n$i. (location i): (value i) per 100,000 population.");
                }
            } else {
                print("\nThe bottom $n (provinces/cities) with the lowest rates of $violation_name in $year_q1 are:\n");
                for($i = 1; $i <= $n; $i++) {
                    print("\n$i. (location i): (value i) per 100,000 population.");
                }
            }
            print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SEE YA! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
        
        }
        $mainFlag = 0; 
    }
}
