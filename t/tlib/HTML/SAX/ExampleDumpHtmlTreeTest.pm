package HTML::SAX::ExampleDumpHtmlTreeTest;

use Test::Unit::Lite;

use base 'Test::Unit::TestCase';

use Text::Diff;
use Test::Assert ':all';
use YAML 'Dump', 'LoadFile';

use HTML::SAX;

sub test_dump_html_tree {
    my $input_html = do {
        ( my $input_html_file = __FILE__ ) =~ s/ExampleDumpHtmlTreeTest.pm$/input.html/;
        open my $fh, '<', $input_html_file or die $!;
        local $/;
        <$fh>;
    };
    assert_true($input_html);

    my $output_yml_data = do {
        ( my $output_yml_file = __FILE__ ) =~ s/ExampleDumpHtmlTreeTest.pm$/output.yml/;
        LoadFile($output_yml_file);
    };
    assert_true($output_yml_data);

    my $handler = HTML::SAX::ExampleDumpHtmlTreeTest::Handler->new;
    my $parser = HTML::SAX->new( rawtext => $input_html, handler => $handler )->parse;

    # Redump original YML, because YAML::Tiny outputs different style.
    my $handler_data_yml = Dump($handler->data);
    my $output_yml = Dump($output_yml_data);
    assert_equals('', diff \$output_yml, \$handler_data_yml, { STYLE => "Table" });
};


package HTML::SAX::ExampleDumpHtmlTreeTest::Handler;
use Any::Moose;
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
