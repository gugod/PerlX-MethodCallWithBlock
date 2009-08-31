#!/usr/bin/env perl -w
use strict;

package Foo;
sub bar {
    my $cb = pop;
    my ($class, @args) = @_;
    $cb->($class, @args);
}

package main;
use Test::More;
use PerlX::MethodCallWithBlock;

Foo->bar(42) {
    pass "the block after bar is called";
};

# TODO: {
#     local $TODO = "Method call without arg list";
#     Foo->bar {
#         pass "the block after bar is called";
#     };
# }

done_testing;
