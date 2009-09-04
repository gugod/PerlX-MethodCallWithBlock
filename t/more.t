#!/usr/bin/env perl
use strict;

package Ping::Pong;
sub ping {
    my $cb = pop;
    $cb->(@_);
}

package main;
use Test::More;
use PerlX::MethodCallWithBlock;

Ping::Pong->ping {
    pass "pong"
};

Ping::Pong->ping(42) {
    pass "pong"
};

my $pp = bless{}, "Ping::Pong";

$pp->ping(42) {
    pass "pong"
};

done_testing;
