#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;

use lib '../lib';

package MyEnum;

sub new {
    my ($class, @x) = @_;
    return bless [ @x ], $class;
}

sub each {
    my ($self, $cb) = @_;

    my $i = 0;
    for my $x (@$self) {
        local $_ = $x;
        $cb->($i++);
    }
}

package main;
use Test::More;
use PerlX::MethodCallWithBlock;

my $x = MyEnum->new(0..10);

$x->each {
    pass "iteration $_";
};

done_testing;
