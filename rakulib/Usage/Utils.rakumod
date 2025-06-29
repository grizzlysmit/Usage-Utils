unit module Usage::Utils:ver<0.1.1>:auth<Francis Grizzly Smit (grizzlysmit@smit.id.au)>;

=begin pod

=head1 Usage::Utils

=begin head2

Table of  Contents

=end head2

=item1 L<NAME|#name>
=item1 L<AUTHOR|#author>
=item1 L<VERSION|#version>
=item1 L<TITLE|#title>
=item1 L<SUBTITLE|#subtitle>
=item1 L<COPYRIGHT|#copyright>
=item1 L<Introduction|#introduction>
=item1 L<grammar UsageStr & action class UsageStrActions|#grammar-usagestr--action-class-usagestractions>
=item1 L<say-coloured(…)|#say-coloured>
=item1 L<You need to implement these or similar in your code|#you-need-to-implement-these-or-similar-in-your-code>


=NAME Usage::Utils 
=AUTHOR Francis Grizzly Smit (grizzly@smit.id.au)
=VERSION v0.1.1
=TITLE Usage::Utils
=SUBTITLE A Raku module to provide syntax highlighting for the B<C<$*USAGE>> string. 

=COPYRIGHT
LGPL V3.0+ L<LICENSE|https://github.com/grizzlysmit/Usage-Utils/blob/main/LICENSE>

L<Top of Document|#table-of-contents>

=head1 Introduction

This is a Raku Module for those who like to colour their Usage messages. 


=end pod

my Bool:D $debug = False;

use Terminal::ANSI::OO :t;
use Terminal::Width;
use Terminal::WCWidth;
#use Grammar::Debugger; $debug = True;
#use Grammar::Tracer;
use Gzz::Text::Utils;
use Parse::Paths;


#`«««
    #########################################################
    #*******************************************************#
    #**                                                   **#
    #**  This grammar is for parsing the usage string     **#
    #**                                                   **#
    #*******************************************************#
    #########################################################
#»»»

=begin pod

=head3 grammar UsageStr & action class UsageStrActions

=begin code :lang<raku>

grammar UsageStr is BasePaths is export {
    token TOP               { ^ 'Usage:' \h* [ \v+ <usage-line> ]+ \v* $ }
    token usage-line        { ^^ \h* <prog> <fixed-args-spec> <pos-spec> <optionals-spec> <slurpy-array-spec> <options-spec> <slurpy-hash-spec> \h* $$ }
    token fixed-args-spec   { [ \h* <fixed-args> ]? }
    token pos-spec          { [ \h* <positional-args> ]? }
    regex optionals-spec    { [ \h* <optionals> ]? }
    regex slurpy-array-spec { [ \h* <slurpy-array> ]? }
    token options-spec      { [ \h* <options> ]? }
    token slurpy-hash-spec  { [ \h* <slurpy-hash> ]? }
    token prog              { [ <prog-name> <!before [ '/' || '~/' || '~' ] > || <base-path> <prog-name> ] }
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

class UsageStrActions does BasePathsActions is export {
    method prog($/) {
        my $prog;
        if $/<base-path> {
            $prog = $/<base-path>.made ~ $/<prog-name>.made;
        } else {
            $prog = $/<prog-name>.made;
        }
        make $prog;
    }
    method prog-name($/) {
        my $prog-name = ~$/;
        make $prog-name;
    }
    ...
    ...
    ...
    ...
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

=end code

=end pod

grammar UsageStr is BasePaths is export {
    token TOP               { ^ 'Usage:' \h* [ \v+ <usage-line> ]+ \v* $ }
    token usage-line        { ^^ \h* <prog> <fixed-args-spec> <pos-spec> <optionals-spec> <slurpy-array-spec> <options-spec> <slurpy-hash-spec> \h* $$ }
    token fixed-args-spec   { [ \h* <fixed-args> ]? }
    token pos-spec          { [ \h* <positional-args> ]? }
    regex optionals-spec    { [ \h* <optionals> ]? }
    regex slurpy-array-spec { [ \h* <slurpy-array> ]? }
    token options-spec      { [ \h* <options> ]? }
    token slurpy-hash-spec  { [ \h* <slurpy-hash> ]? }
    token prog              { [ <prog-name> <!before [ '/' || '~/' || '~' ] > || <base-path> <prog-name> ] }
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
    regex other-opt         { [ '[' <opts> '=<' <type> [ \h+ <where-clause> \h* ]? '>]' ] }
    regex where-clause      { [ 'where' \h* '{' \h* <values> \h* '}' ] }
    regex values            { [ <dots> ] }
    regex dots              { [ '...' ] }
    regex bool-opt          { [ '[' <opts> ']' ] }
    token opts              { <opt> [ '|' <opt> ]* }
    regex opt               { [ <long-opt> || <short-opt> ] }
    regex short-opt         { [ '-' \w ] }
    regex long-opt          { [ '--' \w ** {2 .. Inf} [ '-' \w+ ]* ] }
    regex type              { [ 'Str' || 'Num' || 'Rat' || 'Complex' || [ \w+ [ [ '-' || '::' ] \w+ ]* ] ] }
    regex slurpy-hash       { [ '[--<' [ \w+ [ '-' \w+ ]* ] '>=...]' ] }
}

class UsageStrActions does BasePathsActions is export {
    method prog($/) {
        my $prog;
        if $/<base-path> {
            $prog = $/<base-path>.made ~ $/<prog-name>.made;
        } else {
            $prog = $/<prog-name>.made;
        }
        dd $prog if $debug;
        make $prog;
    }
    method prog-name($/) {
        my $prog-name = ~$/;
        dd $prog-name if $debug;
        make $prog-name;
    }
    method fixed-args-spec($/) {
        my @fixed-args-spec;
        if $/<fixed-args> {
            @fixed-args-spec = $/<fixed-args>.made;
        }
        dd @fixed-args-spec if $debug;
        make @fixed-args-spec;
    }
    method fixed-args($/) {
        my @fixed-args = $/<fixed-arg>».made;
        dd @fixed-args if $debug;
        make @fixed-args;
    }
    method fixed-arg($/) {
        my $fixed-arg = ~$/;
        dd $fixed-arg if $debug;
        make $fixed-arg;
    }
    method pos-spec($/) {
        my @pos-spec;
        if $/<positional-args> {
            @pos-spec = $/<positional-args>.made;
        }
        dd @pos-spec if $debug;
        make @pos-spec;
    }
    method positional-args($/) {
        my @positional-args = $/<positional-arg>».made;
        dd @positional-args if $debug;
        make @positional-args;
    }
    method positional-arg($/) {
        my $positional-arg = ~$/;
        dd $positional-arg if $debug;
        make $positional-arg;
    }
    method optionals-spec($/) {
        my @optionals-spec;
        if $/<optionals> {
            @optionals-spec = $/<optionals>.made;
        }
        dd @optionals-spec if $debug;
        make @optionals-spec;
    }
    method optionals($/) {
        my @optionals = $/<optional>».made;
        dd @optionals if $debug;
        make @optionals;
    }
    method optional($/) {
        my $optional = ~$/;
        dd $optional if $debug;
        make $optional;
    }
    method slurpy-array-spec($/) {
        my $slurpy-array-spec = '';
        if $/<slurpy-array> {
            $slurpy-array-spec = $/<slurpy-array>.made;
        }
        dd $slurpy-array-spec if $debug;
        make $slurpy-array-spec;
    }
    method slurpy-array($/) {
        my $slurpy-array = ~$/;
        dd $slurpy-array if $debug;
        make $slurpy-array;
    }
    method options-spec($/) {
        my @options-spec;
        if $/<options> {
            @options-spec = $/<options>.made;
        }
        dd @options-spec if $debug;
        make @options-spec;
    }
    method options($/) {
        my @options = $/<option>».made;
        dd @options if $debug;
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
        dd $option if $debug;
        make $option;
    }
    method int-opt($/) {
        my $int-opt = '[' ~ $/<opts>.made ~ '[=Int]]';
        dd $int-opt if $debug;
        make $int-opt;
    }
    #`«
    regex other-opt         { [ '[' <opts> '=<' <type> [ \h+ <where-clause> ]? '>]' ] }
    regex where-clause      { [ 'where' \h* '\{' \h* <values> \h* '}' ] }
    regex values            { [ <dots> ] }
    regex dots              { [ '...' ] }
    »
    method dots($/) {
        my $dots = ~$/;
        dd $dots if $debug;
        make $dots;
    }
    method values($/) {
        my $values;
        if $/<dots> {
            $values = $/<dots>.made;
        }
        dd $values if $debug;
        make $values;
    }
    method where-clause($/) {
        my $where-clause = 'where \{ ' ~ $/<values>.made ~ ' }';
        dd $where-clause if $debug;
        make $where-clause;
    }
    method other-opt($/) {
        my $other-opt = '[' ~ $/<opts>.made ~ '=<' ~ $/<type>;
        if $/<where-clause> {
            $other-opt ~= ' ' ~ $/<where-clause>.made ~ ' ';
        }
        $other-opt ~= '>]';
        dd $other-opt if $debug;
        dd $other-opt if $debug;
        make $other-opt;
    }
    method bool-opt($/) {
        my $bool-opt = '[' ~ $/<opts>.made ~ ']';
        dd $bool-opt if $debug;
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
        dd $opt if $debug;
        make $opt;
    }
    method short-opt($/) {
        my $short-opt = ~$/;
        dd $short-opt if $debug;
        make $short-opt;
    }
    method long-opt($/) {
        my $long-opt = ~$/;
        dd $long-opt if $debug;
        make $long-opt;
    }
    method type($/) {
        my $type = ~$/;
        dd $type if $debug;
        make $type;
    }
    method slurpy-hash-spec($/) {
        my $slurpy-hash-spec = '';
        if $/<slurpy-hash> {
            $slurpy-hash-spec = $/<slurpy-hash>.made;
        }
        dd $slurpy-hash-spec if $debug;
        make $slurpy-hash-spec;
    }
    method slurpy-hash($/) {
        my $slurpy-hash = ~$/;
        dd $slurpy-hash if $debug;
        make $slurpy-hash;
    }
    method usage-line($/) {
        my %line = prog => $/<prog>.made, fixed-args => $/<fixed-args-spec>.made,
        positional-args => $/<pos-spec>.made, optionals => $/<optionals-spec>.made,
        slurpy-array => $/<slurpy-array-spec>.made, options => $/<options-spec>.made,
        slurpy-hash => $/<slurpy-hash-spec>.made;
        my %usage-line = kind => 'usage-line', value => %line;
        dd %usage-line if $debug;
        make %usage-line;
    }
    method TOP($made) {
        my %u   = kind => 'usage', value => 'Usage:';
        my @top = %u, |($made<usage-line>».made);
        dd @top if $debug;
        $made.make: @top;
    }
} # class UsageStrActions does PathsActions is export #

=begin pod

=head3 say-coloured(…)

A function to call from within a GENERATE-USAGE(&main, |capture --> Int) 

=begin code :lang<raku>

sub say-coloured(Str:D $USAGE, Bool:D $nocoloured, *%named-args, *@args --> True) is export 

=end code

=end pod

sub say-coloured(Str:D $USAGE, Bool:D $nocoloured, *%named-args, *@args --> True) is export {
    #dd $USAGE;
    my @usage = $USAGE.split("\n");
    my Num:D $limit = ((%named-args«limit»:exists) ?? %named-args«limit».Num !! 75.Num);
    #dd @args, %named-args, $limit;
    my $actions = UsageStrActions;
    #my $test = UsageStr.parse(@usage.join("\x0A"), :enc('UTF-8'), :$actions).made;
    #dd $test, $?NL;
    #dd @usage;
    my @usage-struct = |(UsageStr.parse(@usage.join("\x0A"), :enc('UTF-8'), :$actions).made);
    #dd @usage-struct;
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

=begin pod

L<Top of Document|#table-of-contents>

=head3 You need to implement these or similar in your code

=begin code :lang<raku>


multi sub MAIN('help', Bool:D :n(:nocolor(:$nocolour)) = False, *%named-args, *@args) returns Int {
   my @_args is Array[Str] = |@args[1 .. *];
   #say @_args.shift;
   say-coloured($*USAGE, $nocolour, |%named-args, |@_args);
   exit 0;
}

sub USAGE(Bool:D :n(:nocolor(:$nocolour)) = False, *%named-args, *@args --> Int) {
    say-coloured($*USAGE, False, %named-args, @args);
    exit 0;
}

multi sub GENERATE-USAGE(&main, |capture --> Int) {
    my @capture = |(capture.list);
    my @_capture;
    if @capture && @capture[0] eq 'help' {
        @_capture = |@capture[1 .. *];
    } else {
        @_capture = |@capture;
    }
    my %capture = |(capture.hash);
    if %capture«nocolour» || %capture«nocolor» || %capture«n» {
        say-coloured($*USAGE, True, |%capture, |@_capture);
    } else {
        #dd @capture;
        say-coloured($*USAGE, False, |%capture, |@_capture);
        #&*GENERATE-USAGE(&main, |capture)
    }
    exit 0;
}

=end code

L<Top of Document|#table-of-contents>

=end pod
