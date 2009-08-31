package PerlX::MethodCallWithBlock;
use strict;
use warnings;
use 5.010;
our $VERSION = '0.01';

use B::Hooks::Parser;
use B::Hooks::EndOfScope;
use B::Generate;

sub inject_close_paren {
    my $linestr = B::Hooks::Parser::get_linestr;
    my $offset = B::Hooks::Parser::get_linestr_offset;
    substr($linestr, $offset, 0) = ');';
    B::Hooks::Parser::set_linestr($linestr);
}

sub block_checker {
    my ($op) = shift;
    my $linestr = B::Hooks::Parser::get_linestr;
    my $offset = B::Hooks::Parser::get_linestr_offset;
    my $code = substr($linestr, $offset);
    return unless $code ~~ /^->(?<method_name>\w+)(?<method_args>\(.*\))\s+{/;
    my $method_args = $+{method_args};
    my $method_name = $+{method_name};

    my $injected_code = 'sub { BEGIN { B::Hooks::EndOfScope::on_scope_end(\&PerlX::MethodCallWithBlock::inject_close_paren); }';

    $method_args =~ s/^\(//;
    $method_args =~ s/\)$//;

    $code = "->${method_name}($method_args, $injected_code";

    substr($linestr, $offset) = $code;
    B::Hooks::Parser::set_linestr($linestr);
}

sub import {
    my $linestr = B::Hooks::Parser::get_linestr();
    my $offset  = B::Hooks::Parser::get_linestr_offset();
    substr($linestr, $offset, 0) = 'use B::Hooks::EndOfScope(); use B::OPCheck const => check => \&PerlX::MethodCallWithBlock::block_checker;';
    B::Hooks::Parser::set_linestr($linestr);
}

1;
__END__

=head1 NAME

PerlX::MethodCallWithBlock - A Perl extension, allow method call with bare blocks afterward.

=head1 SYNOPSIS

    use PerlX::MethodCallWithBlock;

    Foo->bar(1, 2, 3) {
      say "and a block";
    };

=head1 DESCRIPTION

PerlX::MethodCallWithBlock is A Perl extension that extends Perl
syntax to allow one bare block follows normal methods calls.

It translate:

    Foo->bar(1, 2, 3) {
      say "and a block";
    };

Into:

    Foo->bar(1, 2, 3, sub {
      say "and a block";
    });

The body of the C<Foo::bar> method sees it as the very last argument.

=head1 NOTICE

This version is released as a proof that it can be done. However, the
internally parsing code for translating codes are very fragile at this
moment.

Also this doesn't work yet:

    Foo->bar {
      say "and a block";
    };

=head1 AUTHOR

Kang-min Liu E<lt>gugod@gugod.orgE<gt>

=head1 SEE ALSO

L<Rubyish>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009, Kang-min Liu C<< <gugod@gugod.org> >>.

This is free software, licensed under:

    The MIT (X11) License

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENSE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut
