package Sort::SubList;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict 'subs', 'vars';
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(sort_sublist);

sub sort_sublist {
    my $cmp_sub    = shift
        or die "Please supply comparison routine (first arg)";
    my $select_sub = shift
        or die "Please supply elemnet selection routine (second arg)";
    my @list = @_;

    my @pos_selected;
    my @selected;

  ELEM:
    for my $i (0..$#_) {
        { local $_ = $list[$i]; next ELEM unless $select_sub->($_) }
        push @selected, $list[$i];
        push @pos_selected, $i;
    }
    @selected = sort { $cmp_sub->($a, $b) } @selected;

    for (0..$#pos_selected) {
        $list[ $pos_selected[$_] ] = $selected[$_];
    }

    @list;
}

1;

# ABSTRACT: Sort only certain elements in a list, while maintaining the order of the rest

=head1 SYNOPSIS

 use Sort::SubList qw(sort_sublist);

 my @sorted = sort_sublist
     sub { length($_[0]) <=> length($_[1]) },  # comparison routine
     sub { /\D/ },                             # element selection routine
     "quux", 12, 1, "us", 400, 3, "a", "foo";

 # => ("a", 12, 1, "us", 400, 3, "foo", "quux")


=head1 DESCRIPTION

This module provides L</sort_sublist> routine to sort only certain elements in a
list, while keeping the order of the rest of the elements intact (in the
original position). So basically what this routine does is to grep the elements
to be sorted, record their positions, sort these elements, and put them back to
the recorded positions.


=head1 FUNCTIONS

=head2 sort_sublist

Usage:

 my @sorted = sort_sublist $comparison_sub, $filter_sub, @list;


=head1 FAQ

=head2 How about adding prototype to C<sort_sublist> so it's more convenient to use like the builtin C<sort>?

The builtin C<sort>'s behavior is hard to emulate with subroutine prototypes.
For more discussion:
L<https://www.perlmonks.org/index.pl/www.mrtg.org?node_id=1207981>. For
simplicity, I do away with prototypes altogether.

=head2 How to use $a and $b in comparison sub, just like when we use builtin C<sort>?

Something like this will do:

    sub {
        no strict 'refs';

        my $caller = caller();
        my $a = @_ ? $_[0] : ${"$caller\::a"};
        my $b = @_ ? $_[1] : ${"$caller\::b"};

        # compare $a and $b ...
    }

Or, you can just use C<$_[0]> (instead of C<$a>) and C<$_[1]> (instead of C<$b>)
like the example in Synopsis shows. Again, this is where the specialness of the
sort subroutine is not easy or straightforward to emulate.


=head1 SEE ALSO
