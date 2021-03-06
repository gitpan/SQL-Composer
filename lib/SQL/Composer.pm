package SQL::Composer;

use strict;
use warnings;

our $VERSION = '0.09';

require Carp;
use SQL::Composer::Select;
use SQL::Composer::Insert;
use SQL::Composer::Delete;
use SQL::Composer::Update;

$Carp::Internal{(__PACKAGE__)}++;
$Carp::Internal{"SQL::Composer::$_"}++ for qw/
  Select
  Insert
  Delete
  Update
  Expression
  Join
  Quoter
  /;

sub build {
    my $class = shift;
    my ($name) = shift;

    my $class_name = 'SQL::Composer::' . ucfirst($name);
    return $class_name->new(@_);
}

1;
__END__

=pod

=head1 NAME

SQL::Composer - sql builder

=head1 SYNOPSIS

    use DBI;

    my $select = SQL::Composer->build('select',
        from    => 'book_description',
        columns => ['description'],
        join    => [
            {
                source  => 'book',
                columns => ['title'],
                on      => ['book_description.book_id' => {-col => 'book.id'}],
                join    => [
                    {
                        source  => 'author',
                        columns => ['name'],
                        on      => ['book.author_id' => {-col => 'author.id'}]
                    }
                ]
            }
        ]
    );

    my $sql  = $select->to_sql;
    my @bind = $select->to_bind;

    my $dbh = DBI->connect(...);
    my $sth = dbh->prepare($sql);
    $sth->execute(@bind);
    my $rows = $sth->fetchall_arrayref;

    my $objects = $select->from_rows($rows);

    # $objects = [
    #   description => 'Nice Book',
    #   book => {
    #       title => 'My Book',
    #       author => {
    #           name => 'Author'
    #       }
    #   }
    # ]

=head1 DESCRIPTION

L<SQL::Composer> is a SQL builder and rows parser in one module. It allows deep
joins and automatic convertion from arrayref to a hashref, keeping the nested
join structure if needed.

This module itself is just a factory for the common SQL statements: C<SELECT>,
C<DELETE>, C<INSERT> and C<UPDATE>.

=head1 METHODS

=head2 C<build>

Build SQL statement.

    my $select = SQL::Composer->build('select, @params);

=head1 SQL

=head2 SQL expressions

SQL expressions are everything used in C<where>, C<join> and other statements.
So the following rules apply to all of them. For more details see
L<SQL::Composer::Expression>.

    my $expr = SQL::Composer::Expression->new(expr => [a => 'b']);

    my $sql = $expr->to_sql;   # `a` = ?
    my @bind = $expr->to_bind; # ('b')

=head2 SQL Joins

For more details see L<SQL::Composer::Join>.

    my $expr = SQL::Composer::Join->new(source => 'table', on => [a => 'b']);

    my $sql = $expr->to_sql;   # JOIN `table` ON `table`.`a` = ?
    my @bind = $expr->to_bind; # ('b')

=head2 SQL Inserts

For more details see L<SQL::Composer::Select>.

    my $expr =
      SQL::Composer::Insert->new(into => 'table', values => [foo => 'bar']);

    my $sql = $expr->to_sql;   # INSERT INTO `table` (`foo`) VALUES (?)
    my @bind = $expr->to_bind; # ('bar')

=head2 SQL Updates

For more details see L<SQL::Composer::Update>.

    my $expr =
      SQL::Composer::Update->new(table => 'table', values => [a => 'b']);

    my $sql = $expr->to_sql;   # UPDATE `table` SET `a` = ?
    my @bind = $expr->to_bind; # ('b')

=head2 SQL Deletes

For more details see L<SQL::Composer::Delete>.

    my $expr = SQL::Composer::Delete->new(from => 'table');

    my $sql = $expr->to_sql;   # DELETE FROM `table`
    my @bind = $expr->to_bind; # ()

=head2 SQL Selects

For more details see L<SQL::Composer::Select>.

    my $expr =
      SQL::Composer::Select->new(from => 'table', columns => ['a', 'b']);

    my $sql = $expr->to_sql;   # SELECT `table`.`a`,`table`.`b` FROM `table`
    my @bind = $expr->to_bind; # ()

    my $objects = $expr->from_rows([['c', 'd']]); # [{a => 'c', b => 'd'}];

=head1 SEE ALSO

L<SQL::Abstract>

=head1 AUTHOR

Viacheslav Tykhanovskyi

=head1 COPYRIGHT AND LICENSE

Copyright 2013, Viacheslav Tykhanovskyi.

This module is free software, you may distribute it under the same terms as Perl.

=cut
