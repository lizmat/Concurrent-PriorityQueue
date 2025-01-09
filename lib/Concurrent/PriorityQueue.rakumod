use Array::Sorted::Util:auth<zef:lizmat>:ver<0.0.11+>;

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

# vim: expandtab shiftwidth=4
