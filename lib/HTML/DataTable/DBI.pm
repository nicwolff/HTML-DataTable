package HTML::DataTable::DBI;
use base HTML::DataTable;

use 5.006;
use strict;
use warnings;

use DBI;

=head1 NAME

HTML::DataTable::DBI - Print HTML tables from SQL queries

=head1 VERSION

Version 0.5

=cut

our $VERSION = 0.5;

=head1 SYNOPSIS

	use HTML::DataTable::DBI;
	my $list = HTML::DataTable::DBI->new(
		data => $cgi_data,
		columns => [
			# hashrefs describing column formats
		],
		sql => 'SELECT * FROM table_name'
	);
	print $list;

=head1 METHODS

Look in HTML::DataTable for column-definition and table formatting attributes

=head3 ADDITIONAL ATTRIBUTES

=head4 dsn

A list containing a DBI connect string, username, and password.

=head4 dbh

You can supply a live DBI database handle instead of a DSN.

=head4 sql

A SQL query with DBI "?" placeholders. That query will be run and its results formatted and shown in the table.

=head4 sql_params

An arrayref containing the actual parameters for the SQL query.

=head4 delete

A hashref telling the list what record to delete. If you include a

=head4 trash_icon

The URL of a trash can icon for use in the "Delete" column – defaults to /art/trash.gif.

=cut

sub set_letter {
	my ($me, $letter) = @_;

	$me->{sql} .= ' WHERE lower(' . $me->{sort}->[0] . ") LIKE '" . lc $letter . "%'";
}

sub set_search {
	my ($me, $letter) = @_;

	$me->{_dbh} ||= $me->{dbh} || DBI->connect( @{ $me->{dsn} } ) || die "No DB connection";

	$me->{sql} .= ' WHERE ' . join ' OR ', map "position( lower(\$1) in lower($_) ) > 0",
		ref $me->{search} eq 'ARRAY' ? @{$me->{search}} : split ' ', $me->{search};
}

sub set_sort_order {
	my $me = shift;

	return unless $me->{sort}->[0];
	$me->{sql} .= ' ORDER BY ' . join ', ', map "$_ $me->{sort_dir}", @{$me->{sort}};
}

sub list_HTML {
	my $me = shift;

	if ( my $d = $me->{delete} ) {
		$me->{trash_icon} ||= '/art/trash.gif';
		my $to_delete = $d->{id} || $d->{foreign};
		if ( $to_delete->[1] ) {
			$me->{_dbh} ||= $me->{dbh} || DBI->connect( @{ $me->{dsn} } ) || die "No DB connection";
			$me->{_dbh}->prepare( $d->{sql} )->execute( $d->{local}[1] || (), $to_delete->[1] );
		}
		push @{$me->{columns}}, {
			style => 'text-align: center; vertical-align: middle;',
			format => sub {
				sprintf '<a href="?%s=%d&delete=%d" onclick="return confirm( &quot;Are you sure you want to delete this %s?&quot; )"><img src="%s"></a>',
					($d->{local} ? @{$d->{local}} : (_noop => 0)),
					$_[$to_delete->[0]],
					$d->{noun} || 'record',
					$me->{trash_icon};
			}
		}
	}

	return $me->SUPER::list_HTML(@_);
}

sub next_row {
	my $me = shift;

	return $me->SUPER::next_row(@_) unless $me->{sql} or $me->{_sth};

	unless ( $me->{_sth} ) {
		$me->{_dbh} ||= $me->{dbh} || DBI->connect( @{ $me->{dsn} } ) || die "No DB connection";
		$me->{_dbh}->trace( $me->{trace} ) if $me->{trace};
		( $me->{_sth} = $me->{_dbh}->prepare( $me->{sql} ) )->execute( @{$me->{sql_params}} );
	}

	my @row = $me->{_sth}->fetchrow or
		do {
			$me->{_sth}->finish;
			$me->{_dbh}->disconnect unless $me->{dbh};
			return undef;
		};

	return \@row;
}

sub format {
	my ($me, $col, $d) = @_;

	return $me->SUPER::format( $col, $d ) unless $col->{sql};

	my (@related);
	$col->{_subquery_sth} ||= $me->{_dbh}->prepare( $col->{sql} );
	$col->{_subquery_sth}->execute( $d->[ $col->{foreign_key_col} || 0 ] );
	while ( my @d = $col->{_subquery_sth}->fetchrow ) {
		push @related, $me->SUPER::format( $col, \@d );
	}

	@related ? join( $col->{separator} || $col->{sep} || ', ', @related ) : $col->{none};
}

1;
