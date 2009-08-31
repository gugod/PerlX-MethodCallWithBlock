use inc::Module::Install;
name 'PerlX-MethodCallWithBlock';
all_from 'lib/PerlX/MethodCallWithBlock.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';

auto_include;
WriteAll;
