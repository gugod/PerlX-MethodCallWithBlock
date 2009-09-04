#!/usr/bin/env perl
use strict;
use 5.010;

package Foo;

sub bar {
    my $cb = pop;
    my ($class, @args) = @_;
    $cb->($class, @args);
}

package main;
use Test::More;
use PerlX::MethodCallWithBlock;

Foo->bar {
    pass "the block after bar is called";
};

done_testing;
