# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)
use strict;

use vars qw($Total_tests);

my $loaded;
my $test_num = 1;
BEGIN { $| = 1; $^W = 1; }
END {print "not ok $test_num\n" unless $loaded;}
print "1..$Total_tests\n";
use UNIVERSAL::require;
$loaded = 1;
ok(1, 'compile');
######################### End of black magic.

# Utility testing functions.
sub ok {
    my($test, $name) = @_;
    print "not " unless $test;
    print "ok $test_num";
    print " - $name" if defined $name;
    print "\n";
    $test_num++;
}

sub eqarray  {
    my($a1, $a2) = @_;
    return 0 unless @$a1 == @$a2;
    my $ok = 1;
    for (0..$#{$a1}) { 
        unless($a1->[$_] eq $a2->[$_]) {
        $ok = 0;
        last;
        }
    }
    return $ok;
}

# Change this to your # of ok() calls + 1
BEGIN { $Total_tests = 9 }

use lib qw(t);

ok( Dummy->require == 23,                       'require()' );
ok( $UNIVERSAL::require::ERROR eq '',           '  $ERROR empty' );
ok( $Dummy::VERSION,                            '  $VERSION ok' );

{
    $SIG{__WARN__} = sub { warn @_ 
                             unless $_[0] =~ /^Subroutine \w+ redefined/ };
    delete $INC{'Dummy.pm'};
    ok( Dummy->require(0.4) == 23,                  'require($version)' );
    ok( $UNIVERSAL::require::ERROR eq '',           '  $ERROR empty' );

    delete $INC{'Dummy.pm'};
    ok( !Dummy->require(1.0),                       'require($version) fail' );
    ok( $UNIVERSAL::require::ERROR =~ 
        /^Dummy version 1 required--this is only version 0.5/ );
}

{
    my $warning = '';
    local $SIG{__WARN__} = sub { $warning = join '', @_ };
    eval 'use UNIVERSAL';
    ok( $warning eq '',     'use UNIVERSAL doesnt interfere' );
}
