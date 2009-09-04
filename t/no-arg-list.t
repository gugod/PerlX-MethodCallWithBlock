#!/usr/bin/env perl
use strict;
use 5.010;
use lib 't/lib';
use Test::More;
use Echo;
use PerlX::MethodCallWithBlock;

Echo->say {
    pass "the block after bar is called";
};

done_testing;
