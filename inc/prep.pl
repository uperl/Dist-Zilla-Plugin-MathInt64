use strict;
use warnings;
use v5.10;
use Path::Class qw( file dir );

my $src = file(__FILE__)->parent
                        ->parent
                        ->parent
                        ->subdir('Math-Int64')
                        ->subdir('c_api_client')
                        ->absolute;
my $dst = file(__FILE__)->parent
                        ->parent
                        ->subdir('share');

foreach my $file ($src->children)
{
  my $fn = $file->basename;
  say $fn;
  $dst->file($fn)->spew(scalar $file->slurp);
}
