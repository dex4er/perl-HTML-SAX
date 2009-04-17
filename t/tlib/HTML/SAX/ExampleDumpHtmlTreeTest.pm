package HTML::SAX::ExampleDumpHtmlTreeTest;

use Test::Unit::Lite;

use Moose;
extends 'Test::Unit::TestCase';

use Test::Assert ':all';
use YAML::Tiny;

use HTML::SAX;

sub test_dump_html_tree {
    my $input_html = do {
        ( my $input_html_file = __FILE__ ) =~ s/ExampleDumpHtmlTreeTest.pm$/input.html/;
        open my $fh, '<', $input_html_file or die $!;
        local $/;
        <$fh>;
    };
    assert_true($input_html);

    ( my $output_yml_file = __FILE__ ) =~ s/ExampleDumpHtmlTreeTest.pm$/output.yml/;
    my $output_yml = YAML::Tiny->read($output_yml_file);
    assert_true($output_yml);

    my $handler = HTML::SAX::ExampleDumpHtmlTreeTest::Handler->new;
    my $parser = HTML::SAX->new( rawtext => $input_html, handler => $handler )->parse;

    assert_deep_equals($output_yml->[0], $handler->data);
};


package HTML::SAX::ExampleDumpHtmlTreeTest::Handler;
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

1;
