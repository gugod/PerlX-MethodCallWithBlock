use inc::Module::Install;
name 'PerlX-MethodCallWithBlock';
all_from 'lib/PerlX/MethodCallWithBlock.pm';

requires
    "B::Hooks::EndOfScope" => "0.08",
    "Devel::Declare"       => "0.005011",
    'B::OPCheck'           => "0.28",
    "PPI"                  => "1.203"
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
