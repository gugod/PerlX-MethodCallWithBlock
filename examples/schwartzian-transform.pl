#!/usr/bin/env perl -w
use strict;
use warnings;
use lib '../lib';
use PerlX::MethodCallWithBlock;
use autobox::Core;
use Perl6::Say;

my $x = [0..10];
$x->map {
    2 * $_
}->map {
    $_ + 1
}->each(\&say);
