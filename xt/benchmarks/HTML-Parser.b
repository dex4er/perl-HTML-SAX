#!/usr/bin/perl

use Benchmark ':all';

open my $fh, 'www.cpan.org.html';
undef $/;
my $html = <$fh>;

use HTML::Parser;

sub start { }
sub end { }

my $parser = HTML::Parser->new(
    api_version => 3,
#    start_h => [\&start, "tagname, attr"],
#    end_h   => [\&end,   "tagname"],
    marked_sections => 1,
);


my $r = timethese ($ARGV[0] || -1, { $0 => sub {

    my $doc = $parser->parse($html);

} } );

cmpthese $r, 'all';
