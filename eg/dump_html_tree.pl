#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib', '../lib';

use HTML::SAX;

my $fh;

if ($ARGV[0]) {
    my $file = $ARGV[0];
    open $fh, '<', $file or die $!;
}
else {
    $fh = \*STDIN;
}

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
        start_element
        empty_element
    }) {
        __PACKAGE__->meta->add_method($method => sub {
            my ($self, $tag, %attrs) = @_;
            push @tree, { $method => { $tag => { %attrs } } };
        });
    };

    foreach my $method (qw{
        characters
        end_element
        cdata
    }) {
        __PACKAGE__->meta->add_method($method => sub {
            my ($self, $data) = @_;
            $data =~ s/^\s*(.*)\s*$/$1/;
            return if $data eq '';
            push @tree, { $method => $data };
        });
    };

    foreach my $method (qw{
        comment
    }) {
        __PACKAGE__->meta->add_method($method => sub {
            my ($self, @data) = @_;
            push @tree, { $method => [ @data ] };
        });
    };

    sub end_document {
        print Dump \@tree;  
    };

};
