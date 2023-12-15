Usage::Utils
============

Table of Contents
-----------------

  * [NAME](#name)

  * [AUTHOR](#author)

  * [VERSION](#version)

  * [TITLE](#title)

  * [SUBTITLE](#subtitle)

  * [COPYRIGHT](#copyright)

  * [Introduction](#introduction)

  * [grammar UsageStr & action class UsageStrActions](#grammar-usagestr--action-class-usagestractions)

  * [Introduction](#introduction)

  * [Introduction](#introduction)

  * [Introduction](#introduction)

  * [Introduction](#introduction)

NAME
====

Usage::Utils 

AUTHOR
======

Francis Grizzly Smit (grizzly@smit.id.au)

VERSION
=======

v0.1.0

TITLE
=====

Usage::Utils

SUBTITLE
========

A Raku module to provide syntax highlighting for the **`$*USAGE`** string. 

COPYRIGHT
=========

LGPL V3.0+ [LICENSE](https://github.com/grizzlysmit/Usage-Utils/blob/main/LICENSE)

Introduction
============

This is a Raku Module for those who like to colour their Usage messages. 

### grammar UsageStr & action class UsageStrActions

```raku
grammar UsageStr is BasePaths is export {
    token TOP               { ^ 'Usage:' [ \v+ <usage-line> ]+ \v* $ }
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
```

### you need to implement these or similar in your code.

```raku
multi sub MAIN('help', Bool:D :n(:nocolor(:$nocolour)) = False, *%named-args, *@args) returns Int {
   my @_args is Array[Str] = |@args[1 .. *];
   #say @_args.shift;
   say-coloured($*USAGE, $nocolour, |%named-args, |@_args);
   exit 0;
}

multi sub MAIN('test') returns Int {
   test();
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
```
