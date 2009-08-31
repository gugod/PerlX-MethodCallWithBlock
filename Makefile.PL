use inc::Module::Install;
name 'PerlX-MethodCallWithBlock';
all_from 'lib/PerlX/MethodCallWithBlock.pm';

requires
    "B::Generate"          => "1.20",
    "B::Hooks::EndOfScope" => "0.08",
    "B::Hooks::Parser"     => "0.09",
    'B::OPCheck' => 0.28
;

tests 't/*.t';
author_tests 'xt';

build_requires
    "Test::More"           => "0.92",
    "Test::Perl::Critic"   => "1.01",
    "Test::Pod"            => "1.40",
    "Test::Spelling"       => "0.11";

auto_include;
auto_set_repository;

WriteAll;
