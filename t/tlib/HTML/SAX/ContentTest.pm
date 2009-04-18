package HTML::SAX::ContentTest;

use Test::Unit::Lite;
use Moose;
extends 'Test::Unit::TestCase';

with 'HTML::SAX::HandlerTestRole';

use Test::Assert ':all';

use HTML::SAX;

sub test_empty {
    my ($self) = @_;
    $self->handler->mock_expect_never('characters');
    $self->handler->mock_expect_never('start_element');
    $self->handler->mock_expect_never('end_element');
    my $parser = HTML::SAX->new( handler => $self->handler, rawtext => '' );
    assert_isa('HTML::SAX', $parser);
    $parser->parse;
};

sub test_simpledata {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content']);
    my $parser = HTML::SAX->new( handler => $self->handler, rawtext => 'content' );
    assert_isa('HTML::SAX', $parser);
    $parser->parse;
};

sub test_preserving_white_space {
return;
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => [" content\t\r\n "]);
    my $parser = HTML::SAX->new( handler => $self->handler, rawtext => " content\t\r\n " );
    assert_isa('HTML::SAX', $parser);
    $parser->parse;
};

1;
