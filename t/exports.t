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
use UNIVERSAL::exports;
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
BEGIN { $Total_tests = 14 }

use lib qw(t);

package Test1;
use Dummy;

::ok( defined &foo );
::ok( foo == 42 );

package YATest1;
use Dummy qw(foo);

::ok( defined &foo );
::ok( foo == 42 );


package Test2;

use Dummy ();

::ok( !defined &foo );


package Test3;

eval { Dummy->import('car') };
my($ok) = $@ =~ /"car" is not exported by the Dummy module/ ? 1 : 0;
::ok( $ok );


package Test4;

use Dummy qw(bar);

::ok( defined &bar and !defined &foo );
::ok( bar == 23 );


# Test UNIVERSAL::exports()
::ok( ::eqarray([sort Dummy->exports], [sort qw(foo bar)]) );
::ok( Dummy->exports('foo') );
::ok( Dummy->exports('bar') );
::ok( !Dummy->exports('car') );
::ok( !Dummy->exports(007) );
