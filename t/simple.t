#!/usr/bin/env perl
use strict;
use lib 't/lib';
use Echo;
use Test::More;
use PerlX::MethodCallWithBlock;

Echo->say(42) {
    pass "the block after bar is called";
};

done_testing;
