#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use lib 't/lib';

use MyEnum;
use Test::More;
use PerlX::MethodCallWithBlock;

my $x = MyEnum->new(0..10);

$x->each {
    pass "iteration $_";
};

done_testing;
