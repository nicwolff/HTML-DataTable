#!perl -T

use Test::More tests => 2;

BEGIN {
    use_ok( 'HTML::DataTable::CGI', 'loading HTML::DataTable::CGI' ) || print "Bail out!\n";
}

BEGIN {
    use_ok( 'HTML::DataTable::DBI', 'loading HTML::DataTable::DBI' ) || print "Bail out!\n";
}