unit module Usage::Utils:ver<0.1.0>:auth<Francis Grizzly Smit (grizzlysmit@smit.id.au)>;

use Terminal::ANSI::OO :t;
use Terminal::Width;
use Terminal::WCWidth;
#use Grammar::Debugger;
#use Grammar::Tracer;
use Gzz::Text::Utils;


#`«««
    #########################################################
    #*******************************************************#
    #**                                                   **#
    #**  This grammar is for parsing the usage string     **#
    #**                                                   **#
    #*******************************************************#
    #########################################################
#»»»


grammar Paths {
    regex path          { [ <absolute-path> || <relative-path> ] }
    regex absolute-path { <lead-in>  <path-segments>? }
    regex lead-in       { [ '/' || '~/' || '~' ] }
    regex relative-path { <path-segments> }
    regex path-segments { <path-segment> [ '/' <path-segment> ]* '/' }
    regex path-segment  { \w+ [ [ '-' || '+' || ':' || '@' || '=' || ',' || '%' || '$' || '.' ]+ \w+ ]* }
}

role PathsActions {
    method lead-in($/) {
        my $leadin = ~$/;
        make $leadin;
    }
    method path($/) {
        my Str $abs-rel-path;
        if $/<absolute-path> {
            $abs-rel-path = $/<absolute-path>.made;
        } elsif $/<relative-path> {
            $abs-rel-path = $/<relative-path>.made;
        }
        make $abs-rel-path;
    }
    method absolute-path($/) {
        my Str $abs-path = $/<lead-in>.made;
        if $/<path-segments> {
            $abs-path ~= $/<path-segments>.made;
        }
        make $abs-path;
    }
    method relative-path($/) {
        my Str $rel-path = '';
        if $/<path-segments> {
            $rel-path ~= $/<path-segments>.made;
        }
        make $rel-path;
    }
    method path-segment($/) {
        my $ps = ~$/;
        make $ps;
    }
    method path-segments($/) {
        my @pss = $/<path-segment>».made;
        make @pss.join('/');
    }
} # role PathsActions #

grammar UsageStr is Paths is export {
    token TOP               { ^ 'Usage:' [ \v+ <usage-line> ]+ \v* $ }
    token usage-line        { ^^ \h* <prog> <fixed-args-spec> <pos-spec> <optionals-spec> <slurpy-array-spec> <options-spec> <slurpy-hash-spec> \h* $$ }
    token fixed-args-spec   { [ \h* <fixed-args> ]? }
    token pos-spec          { [ \h* <positional-args> ]? }
    regex optionals-spec    { [ \h* <optionals> ]? }
    regex slurpy-array-spec { [ \h* <slurpy-array> ]? }
    token options-spec      { [ \h* <options> ]? }
    token slurpy-hash-spec  { [ \h* <slurpy-hash> ]? }
    token prog              { [ <prog-name> <!before [ '/' || '~/' || '~' ] > || <path> <prog-name> ] }
    token prog-name         { \w+ [ [ '-' || '+' || ':' || '@' || '=' || ',' || '%' || '.' ]+ \w+ ]* }
    token fixed-args        { [ <fixed-arg> [ \h+ <fixed-arg> ]* ]? }
    token fixed-arg         {  \w+ [ [ '-' || '+' || ':' || '.' ]+ \w+ ]* }
    regex positional-args   { [ <positional-arg> [ \h+ <positional-arg> ]* ]? }
    regex positional-arg    { '<' \w+ [ '-' \w+ ]* '>' }
    regex optionals         { [ <optional> [ \h+ <optional> ]* ] }
    regex optional          { '[<' [ \w+ [ '-' \w+ ]* ] '>]' }
    regex slurpy-array      { [ '[<' [ \w+ [ '-' \w+ ]* ] '>' \h '...' ']' ] }
    regex options           { [ <option> [ \h+ <option> ]* ] }
    regex option            { [ <int-opt> || <other-opt> || <bool-opt> ] }
    regex int-opt           { [ '[' <opts> '[=Int]]' ] }
    regex other-opt         { [ '[' <opts> '=<' <type> '>]' ] }
    regex bool-opt          { [ '[' <opts> ']' ] }
    token opts              { <opt> [ '|' <opt> ]* }
    regex opt               { [ <long-opt> || <short-opt> ] }
    regex short-opt         { [ '-' \w ] }
    regex long-opt          { [ '--' \w ** {2 .. Inf} [ '-' \w+ ]* ] }
    regex type              { [ 'Str' || 'Num' || 'Rat' || 'Complex' || [ \w+ [ [ '-' || '::' ] \w+ ]* ] ] }
    regex slurpy-hash       { [ '[--<' [ \w+ [ '-' \w+ ]* ] '>=...]' ] }
}

class UsageStrActions does PathsActions is export {
    method prog($/) {
        my $prog;
        if $/<path> {
            $prog = $/<path>.made ~ '/' ~ $/<prog-name>.made;
        } else {
            $prog = $/<prog-name>.made;
        }
        make $prog;
    }
    method prog-name($/) {
        my $prog-name = ~$/;
        make $prog-name;
    }
    method fixed-args-spec($/) {
        my @fixed-args-spec;
        if $/<fixed-args> {
            @fixed-args-spec = $/<fixed-args>.made;
        }
        make @fixed-args-spec;
    }
    method fixed-args($/) {
        my @fixed-args = $/<fixed-arg>».made;
        make @fixed-args;
    }
    method fixed-arg($/) {
        my $fixed-arg = ~$/;
        make $fixed-arg;
    }
    method pos-spec($/) {
        my @pos-spec;
        if $/<positional-args> {
            @pos-spec = $/<positional-args>.made;
        }
        make @pos-spec;
    }
    method positional-args($/) {
        my @positional-args = $/<positional-arg>».made;
        make @positional-args;
    }
    method positional-arg($/) {
        my $positional-arg = ~$/;
        make $positional-arg;
    }
    method optionals-spec($/) {
        my @optionals-spec;
        if $/<optionals> {
            @optionals-spec = $/<optionals>.made;
        }
        make @optionals-spec;
    }
    method optionals($/) {
        my @optionals = $/<optional>».made;
        make @optionals;
    }
    method optional($/) {
        my $optional = ~$/;
        make $optional;
    }
    method slurpy-array-spec($/) {
        my $slurpy-array-spec = '';
        if $/<slurpy-array> {
            $slurpy-array-spec = $/<slurpy-array>.made;
        }
        make $slurpy-array-spec;
    }
    method slurpy-array($/) {
        my $slurpy-array = ~$/;
        make $slurpy-array;
    }
    method options-spec($/) {
        my @options-spec;
        if $/<options> {
            @options-spec = $/<options>.made;
        }
        make @options-spec;
    }
    method options($/) {
        my @options = $/<option>».made;
        make @options;
    }
    method option($/) {
        my $option;
        if $/<int-opt> {
            $option = $/<int-opt>.made;
        } elsif $/<other-opt> {
            $option = $/<other-opt>.made;
        } elsif $<bool-opt> {
            $option = $/<bool-opt>.made;
        }
        make $option;
    }
    method int-opt($/) {
        my $int-opt = '[' ~ $/<opts>.made ~ '[=Int]]';
        make $int-opt;
    }
    method other-opt($/) {
        my $other-opt = '[' ~ $/<opts>.made ~ '=<' ~ $/<type> ~ '>]';
        make $other-opt;
    }
    method bool-opt($/) {
        my $bool-opt = '[' ~ $/<opts>.made ~ ']';
        make $bool-opt;
    }
    method opts($/) {
        my @opts = $/<opt>».made;
        make @opts.join('|');
    }
    method opt($/) {
        my $opt;
        if $/<short-opt> {
            $opt = $/<short-opt>.made;
        } elsif $/<long-opt> {
            $opt = $/<long-opt>.made;
        }
        make $opt;
    }
    method short-opt($/) {
        my $short-opt = ~$/;
        make $short-opt;
    }
    method long-opt($/) {
        my $long-opt = ~$/;
        make $long-opt;
    }
    method type($/) {
        my $type = ~$/;
        make $type;
    }
    method slurpy-hash-spec($/) {
        my $slurpy-hash-spec = '';
        if $/<slurpy-hash> {
            $slurpy-hash-spec = $/<slurpy-hash>.made;
        }
        make $slurpy-hash-spec;
    }
    method slurpy-hash($/) {
        my $slurpy-hash = ~$/;
        make $slurpy-hash;
    }
    method usage-line($/) {
        my %line = prog => $/<prog>.made, fixed-args => $/<fixed-args-spec>.made,
        positional-args => $/<pos-spec>.made, optionals => $/<optionals-spec>.made,
        slurpy-array => $/<slurpy-array-spec>.made, options => $/<options-spec>.made,
        slurpy-hash => $/<slurpy-hash-spec>.made;
        my %usage-line = kind => 'usage-line', value => %line;
        make %usage-line;
    }
    method TOP($made) {
        my %u   = kind => 'usage', value => 'Usage:';
        my @top = %u, |($made<usage-line>».made);
        $made.make: @top;
    }
} # class UsageStrActions does PathsActions is export #

sub say-coloured(Str:D $USAGE, Bool:D $nocoloured, *%named-args, *@args --> True) is export {
    my @usage = $USAGE.split("\n");
    my Num:D $limit = ((%named-args«limit»:exists) ?? %named-args«limit».Num !! 75.Num);
    #dd @args, %named-args, $limit;
    my $actions = UsageStrActions;
    #my $test = UsageStr.parse(@usage.join("\x0A"), :enc('UTF-8'), :$actions).made;
    #dd $test, $?NL;
    my @usage-struct = |(UsageStr.parse(@usage.join("\x0A"), :enc('UTF-8'), :$actions).made);
    my Int:D $width = 0;
    if $nocoloured {
        for @usage-struct -> %line {
            my Str $kind = %line«kind»;
            if $kind eq 'usage' {
                my Str $value = %line«value»;
                $width = max($width,    wcswidth($value));
            } elsif $kind eq 'usage-line' {
                my %value            = %line«value»;
                my Str $prog         = %value«prog»;
                my @fixed-args       = %value«fixed-args»;
                my @positional-args  = %value«positional-args»;
                my @optionals        = %value«optionals»;
                my Str $slurpy-array = %value«slurpy-array»;
                my @options          = %value«options»;
                my Str $slurpy-hash  = %value«slurpy-hash»;
                my Str:D $ln = ' ' x 2;
                $ln ~= $prog ~ ' ';
                for @fixed-args -> $arg {
                    $ln ~= $arg ~ ' ';
                }
                for @positional-args -> $arg {
                    $ln ~= $arg ~ ' ';
                }
                for @optionals -> $arg {
                    $ln ~= $arg ~ ' ';
                }
                $ln ~= $slurpy-array ~ ' ';
                for @options -> $arg {
                    $ln ~= $arg ~ ' ';
                }
                $ln ~= $slurpy-hash ~ ' ';
                $width = max($width,    wcswidth($ln));
            } else {
            }
        } # for @usage -> $line #
        my Int $terminal-width = terminal-width;
        $terminal-width = 80 if $terminal-width === Int;
        $width = min($width, $terminal-width);
        my Bool:D $output = False;
        ''.say;
        plain: for @usage-struct -> %line {
            my Str $kind = %line«kind»;
            if $kind eq 'usage' {
                my Str $value = %line«value»;
                my Str $ref = $value;
                printf("%-*s\n", $width, left($value, $width, :$ref));
            } elsif $kind eq 'usage-line' {
                my %value            = %line«value»;
                my Str $prog         = %value«prog»;
                my @fixed-args       = |%value«fixed-args»;
                my Str:D $arg0 = '';
                $arg0 = @args[0] if @args;
                my @positional-args  = |%value«positional-args»;
                my @optionals        = |%value«optionals»;
                my @posible = |@fixed-args;
                my Int:D $n = min(@posible.elems, @args.elems);
                my Int:D $sum-weights = (($n * ($n + 1)) / 2).Int;
                $sum-weights = 1 if $sum-weights == 0;
                my Int:D $sum = 0;
                loop (my $i = 0; $i < $n; $i++) {
                    my Str:D $arg-current = '';
                    $arg-current = @args[$i].Str unless @args[$i] === Any;
                    $sum += ($n - $i) if @posible[$i] ~~ rx:i/ ^ $arg-current .* $ /;
                }
                my Num $score = $sum.Num / $sum-weights.Num * 100; # get score as a percentage #
                next plain if $score < $limit;
                #next if @fixed-args && @fixed-args[0] !~~ rx:i/ ^ $arg0 .* $ /;
                my Str $slurpy-array = %value«slurpy-array»;
                my @options          = %value«options»;
                my Str $slurpy-hash  = %value«slurpy-hash»;
                my Str:D $ln = ' ' x 2;
                $ln ~= $prog ~ ' ';
                my Str $ref = ' ' x 2 ~ $prog ~ ' ';
                for @fixed-args -> $arg {
                    $ln ~= $arg ~ ' ';
                    $ref ~= $arg ~ ' ';
                }
                for @positional-args -> $arg {
                    $ln ~= $arg ~ ' ';
                    $ref ~= $arg ~ ' ';
                }
                for @optionals -> $arg {
                    $ln ~= $arg ~ ' ';
                    $ref ~= $arg ~ ' ';
                }
                $ln ~= $slurpy-array ~ ' ';
                $ref ~= $slurpy-array ~ ' ';
                for @options -> $arg {
                    $ln ~= $arg ~ ' ';
                    $ref ~= $arg ~ ' ';
                }
                $ln ~= $slurpy-hash ~ ' ';
                $ref ~= $slurpy-hash ~ ' ';
                printf("%-*s\n", $width, left($ln, $width, :$ref));
                $output = True;
            }
        } # for @usage -> $line #
        unless $output {
            for @usage-struct -> %line {
                my Str $kind = %line«kind»;
                if $kind eq 'usage-line' {
                    my %value            = %line«value»;
                    my Str $prog         = %value«prog»;
                    my @fixed-args       = |%value«fixed-args»;
                    my @positional-args  = %value«positional-args»;
                    my @optionals        = %value«optionals»;
                    my Str $slurpy-array = %value«slurpy-array»;
                    my @options          = %value«options»;
                    my Str $slurpy-hash  = %value«slurpy-hash»;
                    my Str:D $ln = ' ' x 2;
                    $ln ~= $prog ~ ' ';
                    my Str $ref = ' ' x 2 ~ $prog ~ ' ';
                    for @fixed-args -> $arg {
                        $ln ~= $arg ~ ' ';
                        $ref ~= $arg ~ ' ';
                    }
                    for @positional-args -> $arg {
                        $ln ~= $arg ~ ' ';
                        $ref ~= $arg ~ ' ';
                    }
                    for @optionals -> $arg {
                        $ln ~= $arg ~ ' ';
                        $ref ~= $arg ~ ' ';
                    }
                    $ln ~= $slurpy-array ~ ' ';
                    $ref ~= $slurpy-array ~ ' ';
                    for @options -> $arg {
                        $ln ~= $arg ~ ' ';
                        $ref ~= $arg ~ ' ';
                    }
                    $ln ~= $slurpy-hash ~ ' ';
                    $ref ~= $slurpy-hash ~ ' ';
                    printf("%-*s\n", $width, left($ln, $width, :$ref));
                    $output = True;
                }
            } # for @usage -> $line #
        }
        ''.say;
        return True;
    }
    for @usage-struct -> %line {
        my Str $kind = %line«kind»;
        if $kind eq 'usage' {
            my Str $value = %line«value»;
            $width = max($width,    wcswidth($value));
        } elsif $kind eq 'usage-line' {
            my %value            = %line«value»;
            my Str $prog         = %value«prog»;
            my @fixed-args       = %value«fixed-args»;
            my @positional-args  = %value«positional-args»;
            my @optionals        = %value«optionals»;
            my Str $slurpy-array = %value«slurpy-array»;
            my @options          = %value«options»;
            my Str $slurpy-hash  = %value«slurpy-hash»;
            my Str:D $ln = ' ' x 2;
            $ln ~= $prog ~ ' ';
            for @fixed-args -> $arg {
                $ln ~= $arg ~ ' ';
            }
            for @positional-args -> $arg {
                $ln ~= $arg ~ ' ';
            }
            for @optionals -> $arg {
                $ln ~= $arg ~ ' ';
            }
            $ln ~= $slurpy-array ~ ' ';
            for @options -> $arg {
                $ln ~= $arg ~ ' ';
            }
            $ln ~= $slurpy-hash ~ ' ';
            $width = max($width,    wcswidth($ln));
        } else {
        }
    } # for @usage -> $line #
    my Int $terminal-width = terminal-width;
    $terminal-width = 80 if $terminal-width === Int;
    $width = min($width, $terminal-width);
    my Bool:D $output = False;
    put t.bg-blue ~ t.bold ~ sprintf("%-*s", $width, left('', $width)) ~ t.text-reset;
    main-for: for @usage-struct -> %line {
        my Str $kind = %line«kind»;
        if $kind eq 'usage' {
            my Str $value = %line«value»;
            my Str $ref = $value;
            put t.bg-blue ~ t.bold ~ t.red ~ sprintf("%-*s", $width, left($value, $width, :$ref)) ~ t.text-reset;
        } elsif $kind eq 'usage-line' {
            my %value            = %line«value»;
            my Str $prog         = %value«prog»;
            my @fixed-args       = |%value«fixed-args»;
            my Str:D $arg0 = '';
            $arg0 = @args[0] if @args;
            my @positional-args  = |%value«positional-args»;
            my @optionals        = |%value«optionals»;
            my @posible = |@fixed-args;
            my Int:D $n = min(@posible.elems, @args.elems);
            my Int:D $sum-weights = (($n * ($n + 1)) / 2).Int;
            $sum-weights = 1 if $sum-weights == 0;
            my Int:D $sum = 0;
            loop (my $i = 0; $i < $n; $i++) {
                my Str:D $arg-current = '';
                $arg-current = @args[$i].Str unless @args[$i] === Any;
                $sum += ($n - $i) if @posible[$i] ~~ rx:i/ ^ $arg-current .* $ /;
            }
            my Num $score = $sum.Num / $sum-weights.Num * 100; # get score as a percentage #
            next main-for if $score < $limit;
            #next if @fixed-args && @fixed-args[0] !~~ rx:i/ ^ $arg0 .* $ /;
            my Str $slurpy-array = %value«slurpy-array»;
            my @options          = %value«options»;
            my Str $slurpy-hash  = %value«slurpy-hash»;
            my Str:D $ln = ' ' x 2;
            $ln ~= t.color(0,255,0) ~ $prog ~ ' ' ~ t.color(255,0,255);
            my Str $ref = ' ' x 2 ~ $prog ~ ' ';
            for @fixed-args -> $arg {
                $ln ~= $arg ~ ' ';
                $ref ~= $arg ~ ' ';
            }
            $ln ~= t.color(255, 0, 0);
            for @positional-args -> $arg {
                $ln ~= $arg ~ ' ';
                $ref ~= $arg ~ ' ';
            }
            $ln ~= t.color(0, 255, 255);
            for @optionals -> $arg {
                $ln ~= $arg ~ ' ';
                $ref ~= $arg ~ ' ';
            }
            $ln ~= t.color(255, 255, 0) ~ $slurpy-array ~ t.red ~ ' ';
            $ref ~= $slurpy-array ~ ' ';
            for @options -> $arg {
                $ln ~= $arg ~ ' ';
                $ref ~= $arg ~ ' ';
            }
            $ln ~= t.color(255, 128, 128) ~ $slurpy-hash ~ ' ';
            $ref ~= $slurpy-hash ~ ' ';
            put t.bg-blue ~ t.bold ~ sprintf("%-*s", $width, left($ln, $width, :$ref)) ~ t.text-reset;
            $output = True;
        }
    } # for @usage -> $line #
    unless $output {
        for @usage-struct -> %line {
            my Str $kind = %line«kind»;
            if $kind eq 'usage-line' {
                my %value            = %line«value»;
                my Str $prog         = %value«prog»;
                my @fixed-args       = |%value«fixed-args»;
                my @positional-args  = %value«positional-args»;
                my @optionals        = %value«optionals»;
                my Str $slurpy-array = %value«slurpy-array»;
                my @options          = %value«options»;
                my Str $slurpy-hash  = %value«slurpy-hash»;
                my Str:D $ln = ' ' x 2;
                $ln ~= t.color(0,255,0) ~ $prog ~ ' ' ~ t.color(255,0,255);
                my Str $ref = ' ' x 2 ~ $prog ~ ' ';
                for @fixed-args -> $arg {
                    $ln ~= $arg ~ ' ';
                    $ref ~= $arg ~ ' ';
                }
                $ln ~= t.color(255, 0, 0);
                for @positional-args -> $arg {
                    $ln ~= $arg ~ ' ';
                    $ref ~= $arg ~ ' ';
                }
                $ln ~= t.color(0, 255, 255);
                for @optionals -> $arg {
                    $ln ~= $arg ~ ' ';
                    $ref ~= $arg ~ ' ';
                }
                $ln ~= t.color(255, 255, 0) ~ $slurpy-array ~ t.red ~ ' ';
                $ref ~= $slurpy-array ~ ' ';
                for @options -> $arg {
                    $ln ~= $arg ~ ' ';
                    $ref ~= $arg ~ ' ';
                }
                $ln ~= t.color(255, 128, 128) ~ $slurpy-hash ~ ' ';
                $ref ~= $slurpy-hash ~ ' ';
                put t.bg-blue ~ t.bold ~ sprintf("%-*s", $width, left($ln, $width, :$ref)) ~ t.text-reset;
                $output = True;
            }
        } # for @usage -> $line #
    }
    put t.bg-blue ~ t.bold ~ sprintf("%-*s", $width, left('', $width)) ~ t.text-reset;
} # sub say-coloured(Str:D $USAGE, Bool:D $nocoloured, *%named-args, *@args --> True) is export #
