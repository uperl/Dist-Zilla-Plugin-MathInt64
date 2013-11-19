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

This plugin imports the C client API from L<Math::Int64> int your
distribution.  The C client API depends on ppport.h, so make sure
that you also get that (the easiest way is via the 
L<PPPort plugin|Dist::Zilla::Plugin::PPPort>.

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

=head1 TODO

=over 4

=item create a typemap file

(if it does not already exist in the dist)

=item munge existing typemap file

(to include 64bit types)

=back

=cut

with 'Dist::Zilla::Role::Plugin';
with 'Dist::Zilla::Role::FileGatherer';

has dir => (
  is => 'ro',
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
}

1;
