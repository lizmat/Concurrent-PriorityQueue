use Array::Sorted::Util:auth<zef:lizmat>:ver<0.0.10>;

role Concurrent::PriorityQueue[
  ::TYPE = Any,
   :&cmp = &infix:<cmp>
] does Positional {
    has TYPE @!keys;
    has      @!values;
    has Lock $!lock;
    has      &!cmp;

    method TWEAK() {
        $!lock := Lock.new;
    }

    proto method STORE(|) {*}
    multi method STORE() { }
    multi method STORE(*@_, :$initialize) {
        $!lock.protect: {
            for @_ {
                $_ ~~ Pair
                  ?? inserts @!keys, .key, @!values, .value
                  !! inserts @!keys, $_,   @!values, $_
            }
        }
    }

    proto method push(|) {*}
    multi method push(::?CLASS:D: *%_) {
        %_ == 1
          ?? self.push(%_.head)
          !! fail "Can only specify 1 named argument with .push"
    }
    multi method push(::?CLASS:D: TYPE:D $_) {
        $!lock.protect: {
            inserts @!keys, $_, @!values, $_, :&cmp, :force;
        }
    }
    multi method push(::?CLASS:D: Pair:D $_) {
        $!lock.protect: {
            inserts @!keys, .key, @!values, .value, :&cmp, :force;
        }
    }

    method shift(::?CLASS:D:) {
        $!lock.protect: {
            @!keys.shift if @!keys.elems;
            @!values.shift
        }
    }

    method pop(::?CLASS:D:) {
        $!lock.protect: {
            @!keys.pop if @!keys.elems;
            @!values.pop
        }
    }

    method List(::?CLASS:D:) {
        $!lock.protect: {
            my $ib := IterationBuffer.new;
            $ib.push( Pair.new(@!keys[$_], @!values[$_]) ) for ^self.elems;
            $ib.List
        }
    }

    method elems(::?CLASS:D:) { @!keys.elems }
}

=begin pod

=head1 NAME

Concurrent::PriorityQueue - provide a thread-safe priority queue

=head1 SYNOPSIS

=begin code :lang<raku>

use Concurrent::PriorityQueue;

my @a is Concurrent::PriorityQueue;

@a.push(666);
@a.push(42);

say @a.shift;  # 42
say @a.shift;  # 666

@a.push(666 => "bar");
@a.push(42  => "foo");

say @a.shift;  # foo
say @a.shift;  # bar

=end code

=head1 DESCRIPTION

Concurrent::PriorityQueue provides a customizable role to create an
ordered queue to which one can C<.push> values to, and <.shift> or
C<.pop> values from.  By default, the underlying order of values
pushed, is in ascending order, using C<infix:<cmp>> semantics.

If a C<Pair> was C<.push>ed, then the C<.key> will determine the
position in the underlying order.  And C<.shift> and C<.pop> will
produce the associated C<.value>.

If any other value was C<.push>ed, then it will both serve as key as
well as value.

=head1 METHODS

=head2 push

=begin code :lang<raku>

@a.push(42);          # key and value same

@a.push(42 => "foo")  # key and value different

=end code

Adds a key or a key/value pair to the queue.

=head2 pop

=begin code :lang<raku>

say @a.pop;  # value associated with highest key

=end code

Produces the value associated with the highest key, and removes that
entry from the queue.  Or produces a C<Failure> if there were no values
in the queue.

=head2 shift

=begin code :lang<raku>

say @a.shift;  # value associated with lowest key

=end code

Produces the value associated with the lowest key, and removes that
entry from the queue.  Or produces a C<Failure> if there were no values
in the queue.

=head2 elems

=begin code :lang<raku>

say @a.elems;  # number of items remaining in queue

=end code

Produces the current number of items in the queue.

=head2 List

=begin code :lang<raku>

@a.List;  # representation for 

=end code

Produces the queue as a C<List> of C<Pair>s.  Intended to be used to
provide more permanent storage for the queue, to later re-initialize
a new queue with.

=head1 PARAMETERIZATION

=begin code :lang<raku>

# only allow Int as key
class IntQueue does Concurrent::PriorityQueue[Int] { }
my @b is IntQueue;

=end code

By default, C<Any> defined value can serve as key.  This can be
parameterized by specifying a type, e.g. C<Int> to only allow
integers as keys.

=begin code :lang<raku>

# only allow Int as key with <=> order semantics
class NumericQueue does Concurrent::PriorityQueue[Int, :cmp(&[<=>])] { }
my @b is NumericQueue;

=end code

By default the C<infix:<cmp>> comparator is used to determine the
order in which values will be produced,  This can be parameterized
with the C<:cmp> named argument, e.g. C<:cmp(&infix«<=>»)> to use
numerical comparisons only.

=head1 INSPIRATION

This module was inspired by Rob Hoelz's
L<PriorityQueue|https://github.com/hoelzro/p6-priorityqueue> module.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Concurrent::PriorityQueue
Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a
L<small sponsorship|https://github.com/sponsors/lizmat/>  would mean a great
deal to me!

=head1 COPYRIGHT AND LICENSE

Copyright 2024 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=raku expandtab sw=4
