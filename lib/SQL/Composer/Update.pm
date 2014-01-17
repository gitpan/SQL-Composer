package SQL::Composer::Update;

use strict;
use warnings;

require Carp;
use SQL::Composer::Quoter;
use SQL::Composer::Expression;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{quoter} =
      $params{quoter} || SQL::Composer::Quoter->new(driver => $params{driver});

    my $sql = '';
    my @bind;

    $sql .= 'UPDATE ';

    $sql .= $self->_quote($params{table});

    if ($params{values} || $params{set}) {
        my $values = $params{values} || $params{set};
        my @values = ref $values eq 'HASH' ? %$values : @$values;

        $sql .= ' SET ';

        my @pairs;
        while (my ($key, $value) = splice @values, 0, 2) {
            push @pairs,
              $self->_quote($key) . ' = ' . (ref($value) ? $$value : '?');
            push @bind, $value unless ref $value;
        }

        $sql .= join ',', @pairs;
    }

    if ($params{where}) {
        my $expr = SQL::Composer::Expression->new(
            quoter => $self->{quoter},
            expr   => $params{where}
        );
        $sql .= ' WHERE ' . $expr->to_sql;
        push @bind, $expr->to_bind;
    }

    $self->{sql}  = $sql;
    $self->{bind} = \@bind;

    return $self;
}

sub to_sql { shift->{sql} }
sub to_bind { @{shift->{bind} || []} }

sub _quote {
    my $self = shift;
    my ($column) = @_;

    return $self->{quoter}->quote($column);
}

1;
__END__

=pod

=head1

SQL::Composer::Update - UPDATE statement

=head1 SYNOPSIS

    my $expr = SQL::Composer::Update->new(
        table  => 'table',
        values => [a => 'b'],
        where  => [c => 'd']
    );

    my $sql = $expr->to_sql;   # 'UPDATE `table` SET `a` = ? WHERE `c` = ?'
    my @bind = $expr->to_bind; # ['b', 'd']

=cut
