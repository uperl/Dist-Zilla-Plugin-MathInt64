# Dist::Zilla::Plugin::MathInt64

Include the Math::Int64 C client API in your distribution

# SYNOPSIS

in your dist.ini

    [PPPort]
    [MathInt64]
    [ModuleBuild]
    mb_class = MyDist::ModuleBuild

in your xs (lib/MyDist.xs):

    #include "EXTERN.h"
    #include "perl.h"
    #include "XSUB.h"
    #include "ppport.h"
    
    /* #define MATH_INT64_NATIVE_IF_AVAILABLE */
    #include "math_int64.h"

See [Math::Int64#C-API](https://metacpan.org/pod/Math::Int64#C-API) for details.

in your Module::Build subclass (inc/MyDist/ModuleBuild.pm):

    package MyDist::ModuleBuild;
    
    use base qw( Module::Build );
    
    sub new
    {
      my($class, %args) = @_;
      $args{c_source} = '.';
      $class->SUPER::new(%args);
    }

# DESCRIPTION

[Math::Int64](https://metacpan.org/pod/Math::Int64) provides an API for Perl and XS modules for dealing
with 64 bit integers.

This plugin imports the C client API from [Math::Int64](https://metacpan.org/pod/Math::Int64) int your
distribution.  The C client API depends on ppport.h, so make sure
that you also get that (the easiest way is via the 
[PPPort plugin](https://metacpan.org/pod/Dist::Zilla::Plugin::PPPort).

# ATTRIBUTES

## dir

Directory to dump the C source and header files into.
If not specified, they go into the distribution root.
If you use this option you probably need to tell the
[PPPort plugin](https://metacpan.org/pod/Dist::Zilla::Plugin::PPPort) to put
the `ppport.h` file in the same place.

    [PPPort]
    filename = xs/ppport.h
    [MathInt64]
    dir = xs

# TODO

- create a typemap file

    (if it does not already exist in the dist)

- munge existing typemap file

    (to include 64bit types)

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
