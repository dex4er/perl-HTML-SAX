package HTML::SAX::ExampleTidyHtmlTest;

use Test::Unit::Lite;

use Moose;
extends 'Test::Unit::TestCase';

use Text::Diff;
use Test::Assert ':all';

use HTML::SAX;

sub test_dump_html_tree {
    my $input_html = do {
        ( my $input_html_file = __FILE__ ) =~ s/ExampleTidyHtmlTest.pm$/input.html/;
        open my $fh, '<', $input_html_file or die $!;
        local $/;
        <$fh>;
    };
    assert_true($input_html);

    my $output_html = do {
        ( my $output_html_file = __FILE__ ) =~ s/ExampleTidyHtmlTest.pm$/output.html/;
        open my $fh, '<', $output_html_file or die $!;
        local $/;
        <$fh>;
    };
    assert_true($output_html);

    my $handler = HTML::SAX::ExampleTidyHtmlTest::Handler->new;
    my $parser = HTML::SAX->new( rawtext => $input_html, handler => $handler )->parse;

    assert_equals('', diff \$output_html, \$handler->data, { STYLE => "Table" });
};


package HTML::SAX::ExampleTidyHtmlTest::Handler;
use Moose;
with 'HTML::SAX::Handler';

has level => ( is => 'rw', isa => 'Num', default => 0 );
has data  => ( is => 'rw', default => '' );

sub empty_element {
    my ($self, $tag, %attrs) = @_;
    my $data = $self->data;
    if ($tag !~ /^(a|abbr|acronym|address|b|br|code|em|i|img|span|strong|sup)$/) {
        $data .= sprintf "\n%s", ' ' x ($self->level * 2);
    };
    $data .= sprintf "<%s%s />",
        $tag,
        join('', map { sprintf " %s='%s'", $_, $attrs{$_} } keys %attrs);
    $self->data($data);
};

sub start_element {
    my ($self, $tag, %attrs) = @_;
    my $data = $self->data;
    if ($tag !~ /^(a|abbr|acronym|address|b|br|code|em|i|img|span|strong|sup)$/) {
        $data .= sprintf "\n%s", ' ' x ($self->level * 2);
    };
    $data .= sprintf "<%s%s>",
        $tag,
        join('', map { sprintf " %s='%s'", $_, $attrs{$_} } keys %attrs);
    $self->level( $self->level + 1 );
    $self->data($data);
};

sub end_element {
    my ($self, $tag) = @_;
    my $data = $self->data;
    $self->level( $self->level - 1 );
    if ($tag =~ /^(body|div|form|head|html|table|tr|ul)$/) {
        $data .= sprintf "\n%s", ' ' x ($self->level * 2);
    };
    $data .= sprintf "</%s>", $tag;
    $self->data($data);
};

sub characters {
    my ($self, $string) = @_;
    my $data = $self->data;
    $string =~ s/^\s+/ /;
    $string =~ s/\s+$/ /;
    $data .= $string;
    $self->data($data);
};

sub cdata {
    my ($self, $string) = @_;
    my $data = $self->data;
    $data .= sprintf "<![CDATA[%s]]>", $string;
    $self->data($data);
};

sub comment {
    my ($self, @string) = @_;
    my $data = $self->data;
    $data .= sprintf "\n%s", ' ' x ($self->level * 2);
    $data .= sprintf "<!--%s-->", join(' -- ', @string);
    $self->data($data);
};

sub end_document {
    my ($self) = @_;
    my $data = $self->data;
    $data .= "\n";
    $self->data($data);
};

1;
