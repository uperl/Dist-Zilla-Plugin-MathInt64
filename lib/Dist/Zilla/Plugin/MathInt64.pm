package Dist::Zilla::Plugin::MathInt64;

use Moose;
use Dist::Zilla::File::InMemory;

# ABSTRACT: Include the Math::Int64 C client API in your distribution
# VERSION

=head1 SYNOPSIS

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
 
 MODULE = MyDist  PACKAGE = MyDist
 
 int64_t
 function_that_returns_64bit_integer()
 
 void
 function_that_takes_64bit_integer(number)
     int64_t number
 
 SV *
 same_idea_but_with_xs(number
     SV *sv_number
   CODE:
     int64_t native_number = SvI64(sv_number);
     ...
     RETVAL = newSVi64(native_number);
   OUTPUT:
     RETVAL

See L<Math::Int64#C-API> for details.

in your Module::Build subclass (inc/MyDist/ModuleBuild.pm):

 package MyDist::ModuleBuild;
 
 use base qw( Module::Build );
 
 sub new
 {
   my($class, %args) = @_;
   $args{c_source} = '.';
   $class->SUPER::new(%args);
 }

=head1 DESCRIPTION

L<Math::Int64> provides an API for Perl and XS modules for dealing
with 64 bit integers.

This plugin imports the C client API from L<Math::Int64> into your
distribution.  The C client API depends on ppport.h, so make sure
that you also get that (the easiest way is via the 
L<PPPort plugin|Dist::Zilla::Plugin::PPPort>.

This plugin will also create an appropriate C<typemap> or update
an existing C<typemap> to automatically support the types C<int64_t>
and C<uint64_t> in your XS code.  (You can turn this off by setting
typemap = 0).

One thing this plugin does NOT do is, it doesn't tell either
L<Module::Build> or L<ExtUtils::MakeMaker> where to find the C
and XS sources.  One way of doing this would be to create 
your own L<Module::Build> subclass and set the C<c_source> attribute
to where the C header and source code go (see the synopsis above
as an example).

=head1 ATTRIBUTES

=head2 dir

Directory to dump the C source and header files into.
If not specified, they go into the distribution root.
If you use this option you probably need to tell the
L<PPPort plugin|Dist::Zilla::Plugin::PPPort> to put
the C<ppport.h> file in the same place.

 [PPPort]
 filename = xs/ppport.h
 [MathInt64]
 dir = xs

=head2 typemap

If set to true (the default), then create a typemap
file if it does not already exist with the appropriate
typemaps for 64 bit integers, or if a typemap already
exists, add the 64 bit integer mappings.

=cut

with 'Dist::Zilla::Role::Plugin';
with 'Dist::Zilla::Role::FileGatherer';
with 'Dist::Zilla::Role::FileMunger';

has dir => (
  is => 'ro',
);

has typemap => (
  is      => 'ro',
  default => 1,
);

has _source_dir => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
    if(defined $ENV{DIST_ZILLA_PLUGIN_MATH64_TEST})
    {
      require Path::Class::Dir;
      require File::ShareDir;
      return Path::Class::Dir->new($ENV{DIST_ZILLA_PLUGIN_MATH64_TEST});
    }
    elsif(defined $Dist::Zilla::Plugin::MathInt64::VERSION)
    {
      require Path::Class::Dir;
      require File::ShareDir;
      return Path::Class::Dir->new(File::ShareDir::dist_dir('Dist-Zilla-Plugin-MathInt64'));
    }
    else
    {
      require Path::Class::File;
      return Path::Class::File->new(__FILE__)
        ->parent
        ->parent
        ->parent
        ->parent
        ->parent
        ->absolute
        ->subdir('share');
    }
  },
);

sub gather_files
{
  my($self) = @_;
  
  foreach my $source_name (qw( perl_math_int64.c  perl_math_int64.h ))
  {
    my $dst = defined $self->dir
    ? join('/', $self->dir, $source_name)
    : $source_name;
  
    $self->log("create $dst");
    $self->add_file(
      Dist::Zilla::File::InMemory->new(
        name    => $dst,
        content => scalar $self->_source_dir->file($source_name)->slurp,
      ),
    );
  }
  
  unless(grep { $_->name eq 'typemap' } @{ $self->zilla->files })
  {
    if($self->typemap)
    {
      $self->log("create typemap");
      $self->add_file(
        Dist::Zilla::File::InMemory->new(
          name    => 'typemap',
          content => "\nINPUT\n\nOUTPUT\n\n",
        ),
      );
    }
  }
}

sub munge_files
{
  my($self) = @_;
  
  return unless $self->typemap;
  
  my($typemap) = grep { $_->name eq 'typemap' } @{ $self->zilla->files };
  
  $self->log("update typemap");
  
  my @preface;
  my @input;
  my @output;
  my $ref = \@preface;
  
  foreach my $line (split /\n/, $typemap->content)
  {
    if($line =~ /^INPUT\s*$/)
    {
      $ref = \@input;
      next;
    }
    elsif($line =~ /^OUTPUT\s*$/)
    {
      $ref = \@output;
      next;
    }
    push @$ref, $line;
  }

  for(\@preface, \@input, \@output)
  { pop @$_ while @$_ > 0 && $_->[-1] =~ /^\s*$/ }
  
  push @preface,
    'int64_t T_INT64', 
    'uint64_t T_UINT64',
    '';
    
  push @input,
    '',
    'T_INT64',
    '  $var = SvI64($arg);',
    '',
    'T_UINT64',
    '  $var = SvU64($arg);',
    '';
  
  push @output,
    '',
    'T_INT64',
    '  $arg = newSVi64($var);',
    '',
    'T_UINT64',
    '  $arg = newSVu64($var);',
    '';
  
  $typemap->content(join "\n", @preface, 'INPUT', @input, 'OUTPUT', @output);
}

1;
