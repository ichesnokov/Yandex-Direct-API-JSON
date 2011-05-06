#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Yandex::Direct::API::JSON' ) || print "Bail out!
";
}

diag( "Testing Yandex::Direct::API::JSON $Yandex::Direct::API::JSON::VERSION, Perl $], $^X" );
