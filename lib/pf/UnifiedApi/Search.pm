package pf::UnifiedApi::Search;

=head1 NAME

pf::UnifiedApi::Search -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Search

=cut

use strict;
use warnings;

our $DEFAULT_LIKE_FORMAT = '%%%s%%';

our %LIKE_FORMAT = (
    not_like    => $DEFAULT_LIKE_FORMAT,
    like        => $DEFAULT_LIKE_FORMAT,
    ends_with   => '%%%s',
    starts_with => '%s%%',
);

our %OP_TO_SQL_OP = (
    equals              => '=',
    not_equals          => '!=',
    greater_than        => '>',
    less_than           => '<',
    greater_than_equals => '>=',
    less_than_equals    => '<=',
    between             => '-between',
    contains            => '-like',
    ends_with           => '-like',
    starts_with         => '-like',
);

our %OP_TO_HANDLER = (
    (
        map { $_ => \&standard_query_to_sql} qw(equals not_equals greater_than less_than greater_than_equals less_than_equals)
    ),
    (
        map { $_ => \&like_query_to_sql } qw (contains ends_with starts_with),
    ),
    between => sub {
        my ($q) = @_;
        return { $q->{field} => { "-between" => $q->{values} } };
    },
    and => sub {
        my ($q) = @_;
        local $_;
        my @sub_queries =
          map { searchQueryToSqlAbstract($_) } @{ $q->{values} };
        if ( @sub_queries == 1 ) {
            return $sub_queries[0];
        }
        return { '-and' => \@sub_queries };
    },
    or => sub {
        my ($q) = @_;
        local $_;
        my @sub_queries =
          map { searchQueryToSqlAbstract($_) } @{ $q->{values} };
        if ( @sub_queries == 1 ) {
            return $sub_queries[0];
        }
        return { '-or' => \@sub_queries };
    }
);

sub standard_query_to_sql {
    my ($q) = @_;
    return { $q->{field} => { $OP_TO_SQL_OP{ $q->{op} } => $q->{value} } };
}

sub like_query_to_sql {
    my ($q) = @_;
    my $value = $q->{value};
    my $op = $q->{op};
    my $format = exists $LIKE_FORMAT{$op} ? $LIKE_FORMAT{$op} : $DEFAULT_LIKE_FORMAT;
    return { $q->{field} => { $OP_TO_SQL_OP{$op} => escape_like($q->{value}, $format) } };
}

sub searchQueryToSqlAbstract {
    my ($query) = @_;
    my $op = $query->{op};
    if (exists $OP_TO_HANDLER{$op} ) {
        return $OP_TO_HANDLER{$op}->($query);
    }

    return "die unsupported op $op"
}

sub find_like_format {
    my ($op) = @_;
    return exists $LIKE_FORMAT{$op} ? $LIKE_FORMAT{$op} : $DEFAULT_LIKE_FORMAT ;
}

sub escape_like {
    my ($value, $format) = @_;
    my $escaped = $value =~ s/([%_\\])/\\$1/g;
    $value = sprintf($format, $value);
    return $escaped ? \[q{? ESCAPE '\\\\'}, $value] : $value;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

1;

