#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib', '../lib';

use HTML::SAX;

my $file = $ARGV[0] || die "Usage: $0 *file*\n";

open my $fh, '<', $file or die $!;
my $data = do { local $/; <$fh> };

my $handler = My::Handler->new;
my $parser = HTML::SAX->new( rawtext => $data, handler => $handler )->parse;


BEGIN {
    package My::Handler;
    use Moose;
    with 'HTML::SAX::Handler';

    BEGIN {
        eval { require YAML::Syck; YAML::Syck->import; 1 }
        or eval { require YAML; YAML->import; 1 };
    };

    my @tree = ();

    foreach my $method (qw{
        characters
        start_element
        end_element
        empty_element
        cdata
        comment
    }) {
        __PACKAGE__->meta->add_method($method => sub {
            shift;
            push @tree, { $method => \@_ };
        });
    };

    sub end_document {
        print Dump \@tree;  
    };

};
