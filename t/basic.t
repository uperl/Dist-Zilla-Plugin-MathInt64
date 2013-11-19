use strict;
use warnings;
use Test::More 0.88;
use Test::DZil;
use Path::Class qw( file dir );

plan tests => 3;

$ENV{DIST_ZILLA_PLUGIN_MATH64_TEST} = file(__FILE__)->parent->parent->absolute->subdir('share')->stringify;

note "share = $ENV{DIST_ZILLA_PLUGIN_MATH64_TEST}";

subtest 'root' => sub {
  plan tests => 3;
  my $tzil = Builder->from_config(
    { dist_root => 'corpus/DZT' },
    {
      add_files => {
        'source/dist.ini' => simple_ini(
          {},
          # [MathInt64]
          'MathInt64',
        ),
      },
    }
  );

  $tzil->build;

  ok grep { $_->name eq 'perl_math_int64.c' } @{ $tzil->files };
  ok grep { $_->name eq 'perl_math_int64.h' } @{ $tzil->files };
  ok grep { $_->name eq 'typemap' } @{ $tzil->files };
};

subtest 'dir' => sub {
  plan tests => 3;
  my $tzil = Builder->from_config(
    { dist_root => 'corpus/DZT' },
    {
      add_files => {
        'source/dist.ini' => simple_ini(
          {},
          # [MathInt64]
          # dir = xs
          [ 'MathInt64' => { dir => 'xs' } ],
        ),
      },
    }
  );

  $tzil->build;

  ok grep { $_->name eq 'xs/perl_math_int64.c' } @{ $tzil->files };
  ok grep { $_->name eq 'xs/perl_math_int64.h' } @{ $tzil->files };
  ok grep { $_->name eq 'typemap' } @{ $tzil->files };
};

subtest 'no typemap' => sub {
  plan tests => 3;
  my $tzil = Builder->from_config(
    { dist_root => 'corpus/DZT' },
    {
      add_files => {
        'source/dist.ini' => simple_ini(
          {},
          # [MathInt64]
          [ 'MathInt64' => { typemap => 0 } ],
        ),
      },
    }
  );

  $tzil->build;

  ok grep { $_->name eq 'perl_math_int64.c' } @{ $tzil->files };
  ok grep { $_->name eq 'perl_math_int64.h' } @{ $tzil->files };
  ok ! grep { $_->name eq 'typemap' } @{ $tzil->files };
};
