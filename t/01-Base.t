#!perl -T

use Test::More tests => 2;

use_ok( 'HTML::DataTable', 'loading HTML::DataTable' );

my $list = HTML::DataTable->new(
	data => { test1 => 1, test2 => 2 },
	columns => [ map { { header => 'Column ' . $_, format => $_ } } 1..5 ],
	rows => [
		[ 1..5 ],
		[ 1..5 ],
		[ 1..5 ],
	],
);

is(
	$list->list_HTML,
	'<table cellspacing="0" cellpadding="1"><tr bgcolor="#eeeeee" valign="bottom" class="nodrag nodrop"><th class="first_col">Column 1</th><th>Column 2</th><th>Column 3</th><th>Column 4</th><th>Column 5</th></tr><tr bgcolor="#ffffff" valign="top" id=""><td class="first_col">2</td><td>3</td><td>4</td><td>5</td><td><span style="color: gray">None</span></td></tr><tr bgcolor="#eeeeee" valign="top" id=""><td class="first_col">2</td><td>3</td><td>4</td><td>5</td><td><span style="color: gray">None</span></td></tr><tr bgcolor="#ffffff" valign="top" id=""><td class="first_col">2</td><td>3</td><td>4</td><td>5</td><td><span style="color: gray">None</span></td></tr></table>'
);