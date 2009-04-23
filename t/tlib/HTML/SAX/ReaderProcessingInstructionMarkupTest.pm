package HTML::SAX::ReaderProcessingInstructionMarkupTest;

use Test::Unit::Lite;
use Moose;
extends 'Test::Unit::TestCase';

with 'HTML::SAX::HandlerTestRole';

use Test::Assert ':all';

use HTML::SAX;

sub test_target_only_processing_instruction {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['<?php ?>']);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<?php ?>',
    ) );
};

sub test_all_processing_instruction {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['<?php print "Hello"; ?>']);
    $self->handler->mock_expect_never('start_element');
    $self->handler->mock_expect_never('end_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<?php print "Hello"; ?>',
    ) );
};

sub test_nested_processing_instruction {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['a<?php print "Hello"; ?>b']);
    $self->handler->mock_expect_never('start_element');
    $self->handler->mock_expect_never('end_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'a<?php print "Hello"; ?>b',
    ) );
};

sub test_truncated_processing_instruction {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<?']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<?',
    ) );
};

sub test_malformed_processing_instruction {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<?>']);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<?>',
    ) );
};

sub test_malformed_processing_instruction_2 {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['<??>']);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<??>',
    ) );
};

sub test_truncated_processing_instruction_target {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<?php']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<?php',
    ) );
};

sub test_truncated_processing_instruction_no_close {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<?php ']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<?php ',
    ) );
};

# The XML declarations are passed as characters() call
# Should be another way?

sub test_xml_decl {
    my ($self) = @_;
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<?xml version="1.0"?>',
    ) );
};

sub test_xml_decl_with_encoding {
    my ($self) = @_;
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<?xml version="1.0" encoding="UTF-8" ?>',
    ) );
};

sub test_xml_decl_with_standalone {
    my ($self) = @_;
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<?xml version="1.0" standalone="yes" ?>',
    ) );
};

sub test_xml_decl_with_encoding_and_standalone {
    my ($self) = @_;
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
    ) );
};

1;
