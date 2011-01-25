#!/usr/bin/perl

use lib 'lib', '../../lib';

BEGIN { $ENV{ANY_MOOSE} = 'Mouse' };

use Benchmark ':all';

open my $fh, 'www.cpan.org.html';
undef $/;
my $html = <$fh>;

use HTML::SAX;

BEGIN {
    package My::Handler;
    use Any::Moose;
    with 'HTML::SAX::Handler';
    __PACKAGE__->meta->make_immutable;
};

my $handler = My::Handler->new;

my $r = timethese ($ARGV[0] || -1, { $0 => sub {

    my $doc = HTML::SAX->new( rawtext => $html, handler => $handler )->parse;

} } );

cmpthese $r, 'all';
