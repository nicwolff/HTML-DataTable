#!perl -T

use Test::More;

eval { require DBD::SQLite };
if ( @! ) {
	plan skip_all => 'We need DBD::SQLite to test HTML::DataTable::DBI';
} else {
	plan tests => 2;
}

use_ok( 'HTML::DataTable::DBI', 'loading HTML::DataTable::DBI' );

my $list = HTML::DataTable::DBI->new(
	data => { test1 => 1, test2 => 2 },
	dsn => [ 'dbi:SQLite:dbname=t/testdb' ],
	sql => 'SELECT * FROM test_table',
	columns => [
		{ header => 'ID', format => 0 },
		{ header => 'Name', format => 1 },
	],
);

is(
	$list->list_HTML,
	'<table cellspacing="0" cellpadding="1"><tr bgcolor="#eeeeee" valign="bottom" class="nodrag nodrop"><th class="first_col">ID</th><th>Name</th></tr><tr bgcolor="#ffffff" valign="top" id=""><td class="first_col">1</td><td>First</td></tr><tr bgcolor="#eeeeee" valign="top" id=""><td class="first_col">2</td><td>Second</td></tr><tr bgcolor="#ffffff" valign="top" id=""><td class="first_col">3</td><td>Third</td></tr></table>'
);