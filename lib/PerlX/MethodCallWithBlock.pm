package PerlX::MethodCallWithBlock;
use strict;
use warnings;
use 5.010;
our $VERSION = '0.02';

use Devel::Declare ();
use B::Hooks::EndOfScope ();

use PPI;
use PPI::Document;

sub inject_close_paren {
    my $linestr = Devel::Declare::get_linestr;
    my $offset = Devel::Declare::get_linestr_offset;
    substr($linestr, $offset, 0) = ');';
    Devel::Declare::set_linestr($linestr);
}

sub block_checker {
    my ($op, @args) = @_;
    my $linestr = Devel::Declare::get_linestr;
    my $offset = Devel::Declare::get_linestr_offset;
    my $code = substr($linestr, $offset);

    my $doc = PPI::Document->new(\$code);

    my $injected_code = 'sub { BEGIN { B::Hooks::EndOfScope::on_scope_end(\&PerlX::MethodCallWithBlock::inject_close_paren); }';

    map {
        my $node = $_;
        my @children = $node->schildren;
        my @classes = map { $_->class } @children;

        if (@children == 4) {
            # find something looks like "Foo::Bar->baz {"
            if ($classes[0] eq 'PPI::Token::Word'
                    && $classes[1] eq 'PPI::Token::Operator'
                    && $children[1]->content eq '->'
                    && $classes[2] eq 'PPI::Token::Word'
                    && $classes[3] eq 'PPI::Structure::Block'
            ) {
                $code = $node->content;
                $code =~ s/\s*\{$/($injected_code/;
                substr($linestr, $offset) = $code;
                Devel::Declare::set_linestr($linestr);
            }
            elsif ($classes[0] eq 'PPI::Token::Operator'
                    && $children[0]->content eq '->'
                    && $classes[1] eq 'PPI::Token::Word'
                    && $classes[2] eq 'PPI::Structure::List'
                    && $classes[3] eq 'PPI::Structure::Block'
            ) {
                $code = $children[0]->content . $children[1]->content;
                my $args = $children[2]->content;
                $args =~ s/\)$/,$injected_code/;
                $code .= $args;

                substr($linestr, $offset) = $code;
                Devel::Declare::set_linestr($linestr);
            }
        }
        elsif (@children == 5) {
            # find something looks like "Foo::Bar->baz(...) {"
            if ($classes[0] eq 'PPI::Token::Word'
                    && $classes[1] eq 'PPI::Token::Operator'
                    && $children[1]->content eq '->'
                    && $classes[2] eq 'PPI::Token::Word'
                    && $classes[3] eq 'PPI::Structure::List'
                    && $classes[4] eq 'PPI::Structure::Block'
            ) {
                $code = $children[0]->content
                    . $children[1]->content
                    . $children[2]->content;
                my $args = $children[3]->content;
                $args =~ s/\)$/,$injected_code/;
                $code .= $args;

                substr($linestr, $offset) = $code;
                Devel::Declare::set_linestr($linestr);
            }
        }
    }
    grep {
        $_->class eq 'PPI::Statement'
    } $doc->schildren;
}

sub pushmark_checker {
    my ($op, @args) = @_;
    my $offset = Devel::Declare::get_linestr_offset;
    $offset += Devel::Declare::toke_skipspace($offset);
    my $linestr = Devel::Declare::get_linestr;
    my $code = substr($linestr, $offset);
    my $doc = PPI::Document->new(\$code);

    map {
        my $node = $_;
        my @children = $node->schildren;
        my @classes = map { $_->class } @children;
        if (@children == 4) {
            if ($classes[0] eq 'PPI::Token::Symbol'
                    && $classes[1] eq 'PPI::Token::Operator'
                    && $children[1]->content eq '->'
                    && $classes[2] eq 'PPI::Token::Word'
                    && $classes[3] eq 'PPI::Structure::Block'
            ) {
                my $injected_code = 'sub { BEGIN { B::Hooks::EndOfScope::on_scope_end(\&PerlX::MethodCallWithBlock::inject_close_paren); }';
                $code = join "", map { $_->content } @children[0,1,2];
                $code .= "($injected_code";
                substr($linestr, $offset) = $code;
                Devel::Declare::set_linestr($linestr);
            }
        }
    }
    grep {
        $_->class eq 'PPI::Statement'
    } $doc->schildren;
}

sub import {
    my $linestr = Devel::Declare::get_linestr();
    my $offset  = Devel::Declare::get_linestr_offset();

    substr($linestr, $offset, 0) = q[use B::OPCheck const => check => \&PerlX::MethodCallWithBlock::block_checker;use B::OPCheck pushmark => check => \&PerlX::MethodCallWithBlock::pushmark_checker;];
    Devel::Declare::set_linestr($linestr);
}

1;
__END__

=head1 NAME

PerlX::MethodCallWithBlock - A Perl extension to allow a bare block after method call

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

Also this is not working yet:

    $obj->some_method {
        ...
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
