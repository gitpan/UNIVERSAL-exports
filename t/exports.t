#!/usr/bin/perl -w

use strict;

use Test::More tests => 16;

BEGIN { use_ok 'UNIVERSAL::exports' }

use lib qw(t);

package Test1;
use Dummy;

::ok( defined &foo );
::is( foo, 42 );

package YATest1;
use Dummy qw(foo);

::ok( defined &foo );
::is( foo, 42 );


package Test2;

use Dummy ();

::ok( !defined &foo );


package Test3;

eval { Dummy->import('car') };
::like( $@, '/"car" is not exported by the Dummy module/' );


package Test4;

use Dummy qw(bar);

::ok( defined &bar and !defined &foo );
::is( bar, 23 );


# Test UNIVERSAL::exports()
::is_deeply( [sort Dummy->exports], [sort qw(foo bar)] );
::ok( Dummy->exports('foo') );
::ok( Dummy->exports('bar') );
::ok( !Dummy->exports('car') );
::ok( !Dummy->exports(007) );


package Test5;

use Dummy 0.5;
::pass;        # if we don't explode, we're ok.


eval "use Dummy 99";
::like($@, '/Dummy version 99 required--this is only version/');
