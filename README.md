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

eval
----

reset
-----

compiler-version
----------------

context-completions
-------------------

SUBROUTINES
===========

context
-------

```raku
my $context = context;
my $cu = CodeUnit.new(:$context);
```




AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/CodeUnit . Comments and Pull Requests are welcome.

If you like this module, or what I'm doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

