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
    use Any::Moose;
    with 'HTML::SAX::Handler';

    has level => ( is => 'rw', isa => 'Num', default => 0 );

    sub empty_element {
        my ($self, $tag, %attrs) = @_;
        if ($tag !~ /^(a|abbr|acronym|address|b|br|code|em|i|img|span|strong|sup)$/) {
            printf "\n%s", ' ' x ($self->level * 2);
        };
        printf "<%s%s />",
            $tag,
            join('', map { sprintf " %s='%s'", $_, $attrs{$_} } keys %attrs);
    };

    sub start_element {
        my ($self, $tag, %attrs) = @_;
        if ($tag !~ /^(a|abbr|acronym|address|b|br|code|em|i|img|span|strong|sup)$/) {
            printf "\n%s", ' ' x ($self->level * 2);
        };
        printf "<%s%s>",
            $tag,
            join('', map { sprintf " %s='%s'", $_, $attrs{$_} } keys %attrs);
        $self->level( $self->level + 1 );
    };

    sub end_element {
        my ($self, $tag) = @_;
        $self->level( $self->level - 1 );
        if ($tag =~ /^(body|div|form|head|html|table|tr|ul)$/) {
            printf "\n%s", ' ' x ($self->level * 2);
        };
        printf "</%s>", $tag;
    };

    sub characters {
        my ($self, $data) = @_;
        $data =~ s/^\s+/ /;
        $data =~ s/\s+$/ /;
        print $data;
    };

    sub cdata {
        my ($self, $data) = @_;
        printf "<![CDATA[%s]]>", $data;
    };

    sub comment {
        my ($self, @data) = @_;
        printf "\n%s", ' ' x ($self->level * 2);
        printf "<!--%s-->", join(' -- ', @data);
    };

    sub end_document {
        my ($self) = @_;
        printf "\n";  
    };
};
