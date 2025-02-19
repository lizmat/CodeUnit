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

The `new` method instantiates a `CodeUnit` object. It takes an options `:context` named argument, which should be specified with a value returned by the `context` subroutine.

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

SUBROUTINES
===========

context
-------

```raku
my $context = context;
my $cu = CodeUnit.new(:$context);
```

The `context` subroutine returns a context object that can be used to initialize the context of a code unit with.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/CodeUnit . Comments and Pull Requests are welcome.

If you like this module, or what I'm doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

