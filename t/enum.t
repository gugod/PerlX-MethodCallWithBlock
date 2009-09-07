#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use PerlX::MethodCallWithBlock;
use lib 't/lib';

use MyEnum;
use Test::More;

my $x = MyEnum->new(0..10);

$x->each {
    pass "iteration $_";
};

done_testing;
