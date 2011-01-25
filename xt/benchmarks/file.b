#!/usr/bin/perl

use Benchmark ':all';

my $r = timethese ($ARGV[0] || -1, { $0 => sub {

    open my $fh, 'www.cpan.org.html';
    undef $/;
    my $html = <$fh>;

} } );

cmpthese $r, 'all';
