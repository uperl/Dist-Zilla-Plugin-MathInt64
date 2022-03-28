# Dist::Zilla::Plugin::MathInt64 ![static](https://github.com/uperl/Dist-Zilla-Plugin-MathInt64/workflows/static/badge.svg) ![linux](https://github.com/uperl/Dist-Zilla-Plugin-MathInt64/workflows/linux/badge.svg) ![windows](https://github.com/uperl/Dist-Zilla-Plugin-MathInt64/workflows/windows/badge.svg)

Include the Math::Int64 C client API in your distribution

# SYNOPSIS

in your dist.ini

```
[PPPort]
[MathInt64]
[ModuleBuild]
mb_class = MyDist::ModuleBuild
```

in your xs (lib/MyDist.xs):

```
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

/* provides int64_t and uint64_t if not   *
 * already available                      */
#include "perl_math_int64_types.h"

/* #define MATH_INT64_NATIVE_IF_AVAILABLE */
#include "perl_math_int64.h"

MODULE = MyDist  PACKAGE = MyDist

int64_t
function_that_returns_64bit_integer()

void
function_that_takes_64bit_integer(number)
    int64_t number

SV *
same_idea_but_with_xs(sv_number)
    SV *sv_number
  CODE:
    int64_t native_number = SvI64(sv_number);
    ...
    RETVAL = newSVi64(native_number);
  OUTPUT:
    RETVAL
```

See [Math::Int64#C-API](https://metacpan.org/pod/Math::Int64#C-API) for details.

in your Module::Build subclass (inc/MyDist/ModuleBuild.pm):

```perl
package MyDist::ModuleBuild;

use base qw( Module::Build );

sub new
{
  my($class, %args) = @_;
  $args{c_source} = '.';
  $class->SUPER::new(%args);
}
```

# DESCRIPTION

[Math::Int64](https://metacpan.org/pod/Math::Int64) provides an API for Perl and XS modules for dealing
with 64 bit integers.

This plugin imports the C client API from [Math::Int64](https://metacpan.org/pod/Math::Int64) into your
distribution.  The C client API depends on ppport.h, so make sure
that you also get that (the easiest way is via the 
[PPPort plugin](https://metacpan.org/pod/Dist::Zilla::Plugin::PPPort).

This plugin will also create an appropriate `typemap` or update
an existing `typemap` to automatically support the types `int64_t`
and `uint64_t` in your XS code.  (You can turn this off by setting
typemap = 0).

This plugin will also declare [Math::Int64](https://metacpan.org/pod/Math::Int64) as a prerequisite for
your distribution.

One thing this plugin does NOT do is, it doesn't tell either
[Module::Build](https://metacpan.org/pod/Module::Build) or [ExtUtils::MakeMaker](https://metacpan.org/pod/ExtUtils::MakeMaker) where to find the C
and XS sources.  One way of doing this would be to create 
your own [Module::Build](https://metacpan.org/pod/Module::Build) subclass and set the `c_source` attribute
to where the C header and source code go (see the synopsis above
as an example).

# ATTRIBUTES

## dir

Directory to dump the C source and header files into.
If not specified, they go into the distribution root.
If you use this option you probably need to tell the
[PPPort plugin](https://metacpan.org/pod/Dist::Zilla::Plugin::PPPort) to put
the `ppport.h` file in the same place.

```
[PPPort]
filename = xs/ppport.h
[MathInt64]
dir = xs
```

## typemap

If set to true (the default), then create a typemap
file if it does not already exist with the appropriate
typemaps for 64 bit integers, or if a typemap already
exists, add the 64 bit integer mappings.

## typemap\_path

The path to the typemap file (if typemap is true).
The default is simply 'typemap'.

# CAVEATS

This plugin uses [ExtUtils::Typemaps](https://metacpan.org/pod/ExtUtils::Typemaps) to munge the typemaps
file, which strips any comments from the typemap file, but
should be semantically identical.  Versions prior to 0.05
did its own parsing but would retain comments.

# BUNDLED SOFTWARE

This distribution comes bundled with C source code placed
in the public domain by Salvador Fandino.

Thanks to Salvador Fandino for writing [Math::Int64](https://metacpan.org/pod/Math::Int64) and
providing a XS / C Client API for other distribution authors.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
