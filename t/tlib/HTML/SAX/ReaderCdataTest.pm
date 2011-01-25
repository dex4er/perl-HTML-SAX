package HTML::SAX::ReaderCdataTest;

use Test::Unit::Lite;
use Any::Moose;
use if Any::Moose::mouse_is_preferred, 'MouseX::Foreign';
extends 'Test::Unit::TestCase';

with 'HTML::SAX::HandlerTestRole';

use Test::Assert ':all';

use HTML::SAX;

sub test_empty_comment {
    my ($self) = @_;
    $self->handler->mock_expect_once('comment', args => ['']);
    $self->handler->mock_expect_never('characters');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!---->',
    ) );
};

sub test_cdata {
    my ($self) = @_;
    $self->handler->mock_expect_once(
        'cdata',
        args => ['string = \'A CDATA block\';'],
    );
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<![CDATA[string = \'A CDATA block\';]]>',
    ) );
};

sub test_cdata2 {
    my ($self) = @_;
    $self->handler->mock_expect_once('cdata', args => ['<tag>']);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<![CDATA[<tag>]]>',
    ) );
};

sub test_cdata_pre_post {
    my ($self) = @_;
    $self->handler->mock_expect_at(0, 'characters', args => ['abc']);
    $self->handler->mock_expect_at(1, 'cdata', args => ['string = \'A CDATA block\';']);
    $self->handler->mock_expect_at(2, 'characters', args => ['def']);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'abc<![CDATA[string = \'A CDATA block\';]]>def',
    ) );
};

1;
