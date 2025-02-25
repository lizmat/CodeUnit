[![Actions Status](https://github.com/lizmat/CodeUnit/actions/workflows/linux.yml/badge.svg)](https://github.com/lizmat/CodeUnit/actions) [![Actions Status](https://github.com/lizmat/CodeUnit/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/CodeUnit/actions) [![Actions Status](https://github.com/lizmat/CodeUnit/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/CodeUnit/actions)

NAME
====

CodeUnit - provide a unit for execution of code

SYNOPSIS
========

```raku
use CodeUnit;

my $cu = CodeUnit.new;
$cu.eval('my $a = 42');
$cu.eval('say $a');  # 42

$cu.eval('say $b');
with $cu.exception {
    note .message.chomp;  # Variable '$b' is not declared...
    $cu.exception = Nil;
}
```

DESCRIPTION
===========

The `CodeUnit` distribution provides an interface to a compiler context that allows code to be evaluated by given strings, while maintaining context between states.

As such it provides one of the underlying functionalities of a REPL (Read Evaluate Print Loop), but could be used by itself for a multitude of uses.

METHODS
=======

new
---

```raku
my $cu1 = CodeUnit.new;

my $context = context;
my $cu1 = CodeUnit.new(:$context);
```

The `new` method instantiates a `CodeUnit` object. It takes the following named arguments:

### :context

Optional. The `:context` named argument can be specified with a value returned by the `context` subroutine. If not specified, will assume a fresh context without any outer / caller lexicals visible.

Used value available with the `.context` method.

### :compiler

Optional. The `:compiler` named argument can be specified to indicate the low level compiler object that sould be used. Can be specified as a string, in which case it will be used as an argument to the `nqp::getcomp` function to obtain the low level compiler object. Defaults to `"Raku"`.

Used value available with the `.compiler` method.

### :multi-line-ok

Optional, Boolean. Indicate whether it is ok to interprete multiple lines of input as a single statement to evaluate. Defaults to `True` unless the `RAKUDO_DISABLE_MULTILINE` environment variable has been specified with a true value.

Used value available with the `.multi-line-ok` method, and can be used as a left-value to change.

eval
----

```raku
$cu.eval('my $a = 42');
$cu.eval('say $a');  # 42
```

The `eval` method evaluates the given string with Raku code within the context of the code unit, and returns the result of the evaluation.

reset
-----

```raku
$cu.reset;
```

The `reset` method resets the context of the code unit to its initial state as (implicitely) specified with `.new`.

compiler-version
----------------

```raku
say $cu.compiler-version;
# Welcome to Rakudo™ v2025.01.
# Implementing the Raku® Programming Language v6.d.
# Built on MoarVM version 2025.01.
```

The `compiler-version` method returns the compiler version information, which is typically shown when starting a REPL.

context-completions
-------------------

```raku
.say for $cu.context-completions;
```

The `context-completions` method returns an unsorted list of context completion candidates found in the context of the code unit, which are typically used to provide completions in a REPL (hence the name).

state
-----

The `state` method returns one of the `Status` enums to indicate the result of the last call to `.eval`. It can also be used as a left-value to set the state (usually to `OK`).

exception
---------

```raku
with $cu.exception {
    note .message.chomp;  # Variable '$b' is not declared...
    $cu.exception = Nil;
}
```

The `exception` method returns the `Exception` object if anything went wrong in the `.eval` call. Note that this can also be the case even if the state is `OK`. Can also be used as a left-value to (re)set.

ENUMS
=====

Status
------

The `Status` enum is exported: it is used by the `state` method to indicate the state of the last call to `.eval`. It provides the following states:

  * OK (0) - evalution ok

  * MORE-INPUT (1) - string looks like incomplete code

  * CONTROL (2) - some kind of control statement was executed

SUBROUTINES
===========

context
-------

```raku
my $context = context;
my $cu = CodeUnit.new(:$context);
```

The `context` subroutine returns a context object that can be used to initialize the context of a code unit with.

CAVEATS
=======

"Invisible" variables
---------------------

By default, Raku does a lot of compile-time as well as run-time optimizations. This may lead to lexical variables being optimized away, and thus become "invisible" to introspection. If that appears to be the case, then starting Raku with `--optimize=off` may make these "invisble" variables visible.

Each call is a scope
--------------------

Because each call introduces its own scope, certain side-effects of this scoping behaviour may produce unexpected results and/or errors. For example: `my $a = 42`, followed by `say $a`, is really:

```raku
my $a = 42;
{
    say $a;
}
```

This works because the lexical variable `$a` is visible from the scope that has the `say`.

Another example which you might expect to give at least a warning, but doesn't: `my $a = 42;` followed by `my $a = 666`, which would normally produce a worry: "Redeclaration of symbol '$a'", but doesn't here because they are different scopes:

```raku
my $a = 42;
{
    my $a = 666;
}
```

As you can see, the second `$a` shadows the first `$a`, and is not a worry as such.

Future versions of `CodeUnit` may be able to work around this scoping behaviour.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/CodeUnit . Comments and Pull Requests are welcome.

If you like this module, or what I'm doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

