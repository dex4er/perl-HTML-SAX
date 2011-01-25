#!/usr/bin/perl

use Benchmark ':all';

open my $fh, 'www.cpan.org.html';
undef $/;
my $html = <$fh>;

use XML::LibXML;
my $parser = XML::LibXML->new;
$parser->no_network(1);
$parser->recover_silently(1);

my $r = timethese ($ARGV[0] || -1, { $0 => sub {

    my $doc = $parser->parse_string($html);

} } );

cmpthese $r, 'all';
