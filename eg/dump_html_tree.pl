#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib', '../lib';

use HTML::SAX;

BEGIN {
    eval q{ use YAML::Syck; 1 } or
    eval q{ use YAML::Tiny; 1 } or
    eval q{ use YAML; 1 } or
    die $@;
};

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

print Dump($handler->data);


BEGIN {
    package My::Handler;
    use Moose;
    with 'HTML::SAX::Handler';

    has 'data' => ( is => 'rw', default => sub { [] } );

    foreach my $method (qw{
        start_document
    }) {
        __PACKAGE__->meta->add_method($method => sub {
            my ($self, $parser, $data) = @_;
            push @{ $self->data }, { $method => $data };
        });
    };

    foreach my $method (qw{
        end_document
    }) {
        __PACKAGE__->meta->add_method($method => sub {
            my ($self) = @_;
            push @{ $self->data }, { $method => undef };
        });
    };

    foreach my $method (qw{
        start_element
        empty_element
    }) {
        __PACKAGE__->meta->add_method($method => sub {
            my ($self, $tag, %attrs) = @_;
            push @{ $self->data }, { $method => { $tag => { %attrs } } };
        });
    };

    foreach my $method (qw{
        characters
        end_element
        cdata
    }) {
        __PACKAGE__->meta->add_method($method => sub {
        my ($self, $data) = @_;
            push @{ $self->data }, { $method => $data };
        });
    };

    foreach my $method (qw{
        comment
    }) {
        __PACKAGE__->meta->add_method($method => sub {
            my ($self, @data) = @_;
            push @{ $self->data }, { $method => [ @data ] };
        });
    };
};
