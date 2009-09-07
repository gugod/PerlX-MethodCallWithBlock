#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use PerlX::MethodCallWithBlock;
use Test::More;
use autobox;
use autobox::Core;

[0..9]->map {
    2 * $_
}->map {
    is($_ % 2, 0, "$_ mod 2 is 0");
};

done_testing;

