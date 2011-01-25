package HTML::SAX::ReaderCommentTest;

use Test::Unit::Lite;
use Any::Moose;
use if Any::Moose::mouse_is_preferred, 'MouseX::Foreign';
extends 'Test::Unit::TestCase';

with 'HTML::SAX::HandlerTestRole';

use Test::Assert ':all';

use HTML::SAX;

# HTML 4.0:   Valid Markup
# XML 1.1:    Valid Markup
sub test_empty_comment {
    my ($self) = @_;
    $self->handler->mock_expect_once('comment', args => ['']);
    $self->handler->mock_expect_never('characters');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!---->',
    ) );
};

# HTML 4.0:   Valid Markup see http://www.w3.org/MarkUp/SGML/sgml-lex/sgml-lex
# XML 1.1:    Valid Markup
sub test_simple_comment {
    my ($self) = @_;
    $self->handler->mock_expect_once('comment', args => [' xyz ']);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!-- xyz -->',
    ) );
};

# HTML 4.0:   Valid Markup
# XML 1.1:    Valid Markup
sub test_nasty_comment {
    my ($self) = @_;
    $self->handler->mock_expect_once(
        'comment',
        args => [' <tag></tag><?php ?><% %> ']
    );
    $self->handler->mock_expect_never('characters');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<tag><!-- <tag></tag><?php ?><% %> --></tag>',
    ) );
};

# XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
sub test_not_well_formed_comment {
    my ($self) = @_;
    $self->handler->mock_expect_once(
        'characters',
        args => ['<!-- B+, B, or B--->']
    );
    $self->handler->mock_expect_never('comment');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!-- B+, B, or B--->',
    ) );
};

# HTML 4.0:   Valid Markup see http://www.w3.org/MarkUp/SGML/sgml-lex/sgml-lex
# XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
sub test_compound_comment {
    my ($self) = @_;
    $self->handler->mock_expect_once('comment', args => [' xyz ', 'def']);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!-- xyz -- --def-->',
    ) );
};

# HTML 4.0:   Valid Markup see http://www.w3.org/MarkUp/SGML/sgml-lex/sgml-lex
# XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
sub test_compound_comment2 {
    my ($self) = @_;
    $self->handler->mock_expect_once('comment', args => ['', '', '']);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!---- ---- ---->',
    ) );
};

# HTML 4.0:   Valid Markup see http://www.w3.org/MarkUp/SGML/sgml-lex/sgml-lex
# XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
sub test_compound_comment3 {
    my ($self) = @_;
    $self->handler->mock_expect_once('comment', args => ['', '', '']);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!------------>',
    ) );
};

# HTML 4.0:   Invalid Markup see http://www.w3.org/MarkUp/SGML/sgml-lex/sgml-lex
# XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
sub test_malformed_comment {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['<!--x->']);
    $self->handler->mock_expect_never('comment');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!--x->',
    ) );
};

# HTML 4.0:   Invalid Markup see http://www.w3.org/MarkUp/SGML/sgml-lex/sgml-lex
# XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
sub test_malformed_comment2 {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['<!-- comment-- xxx>']);
    $self->handler->mock_expect_never('comment');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!-- comment-- xxx>',
    ) );
};

# HTML 4.0:   Invalid Markup see http://www.w3.org/MarkUp/SGML/sgml-lex/sgml-lex
# XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
sub test_malformed_comment3 {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['<!-- comment -- ->']);
    $self->handler->mock_expect_never('comment');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!-- comment -- ->',
    ) );
};

# HTML 4.0:   Invalid Markup see http://www.w3.org/MarkUp/SGML/sgml-lex/sgml-lex
# XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
sub test_malformed_comment4 {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['<!----->']);
    $self->handler->mock_expect_never('comment');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!----->',
    ) );
};

# HTML 4.0:   Valid markup
# XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
#
# see http://www.hixie.ch/tests/adhoc/html/parsing/compat/008.html
sub test_commented_tag {
    my ($self) = @_;
    $self->handler->mock_expect_once('comment', args => ['><span><!']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!--><span><!-->',
    ) );
};

# HTML 4.0:   Valid markup
# XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
#
# see http://www.hixie.ch/tests/adhoc/html/parsing/comments/001.html
sub test_nexted_comment_confusion {
    my ($self) = @_;
    $self->handler->mock_expect_at(0, 'comment', args => ['', '><!']);
    $self->handler->mock_expect_at(1, 'comment', args => ['', '-><!']);
    $self->handler->mock_expect_call_count('comment', 2);
    $self->handler->mock_expect_once('characters', args => ['PASS']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!------><!-->PASS<!-------><!-->',
    ) );
};

# HTML 4.0:   Invalid Markup
# XML 1.1:    Not well-formed
#
# see http://www.hixie.ch/tests/adhoc/html/parsing/comments/002.html
sub test_malformed_comment5 {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['<!-- --FAIL>']);
    $self->handler->mock_expect_never('comment');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!-- --FAIL>',
    ) );
};

# HTML 4.0:   Invalid Markup
# XML 1.1:    Not well-formed
#
# see http://www.hixie.ch/tests/adhoc/html/parsing/comments/003.html
sub test_malformed_comment6 {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['<!-- --- FAIL --- -->']);
    $self->handler->mock_expect_never('comment');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!-- --- FAIL --- -->',
    ) );
};

# HTML 4.0:   Valid Markup
# XML 1.1:    Not well-formed
#
# see http://www.hixie.ch/tests/evil/mixed/comments-evil.html
sub test_compound_comment7 {
    my ($self) = @_;
    $self->handler->mock_expect_once('comment', args => [' ->incorrect<!- ']);
    $self->handler->mock_expect_never('characters');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!-- ->incorrect<!- -->',
    ) );
};

# HTML 4.0:   Valid Markup
# XML 1.1:    Not well-formed
#
# see http://www.hixie.ch/tests/evil/mixed/comments-evil.html
sub test_compound_comment8 {
    my ($self) = @_;
    $self->handler->mock_expect_once('comment', args => [' ', '>incorrect<!', '']);
    $self->handler->mock_expect_never('characters');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!-- ---->incorrect<!------>',
    ) );
};

# HTML 4.0:   Valid Markup
# XML 1.1:    Not well-formed
#
# see http://www.hixie.ch/tests/evil/mixed/comments-evil.html
sub test_compound_comment9 {
    my ($self) = @_;
    $self->handler->mock_expect_once('comment', args => ['', '>incorrect<!', '']);
    $self->handler->mock_expect_never('characters');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!------>incorrect<!------>',
    ) );
};

# HTML 4.0:   Valid Markup
# XML 1.1:    Not well-formed
#
# see http://www.hixie.ch/tests/evil/mixed/comments-evil.html
sub test_compound_comment10 {
    my ($self) = @_;
    $self->handler->mock_expect_once('comment', args => ['', '>incorrect<!', '']);
    $self->handler->mock_expect_never('characters');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!---- -->incorrect<!------>',
    ) );
};

# HTML 4.0:   Valid Markup
# XML 1.1:    Not well-formed
#
# see http://www.hixie.ch/tests/evil/mixed/comments-evil.html
sub test_compound_comment11 {
    my ($self) = @_;
    $self->handler->mock_expect_once('comment', args => [' ', '>incorrect<!', ' ']);
    $self->handler->mock_expect_never('characters');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<!-- -- -->incorrect<!-- -- -->',
    ) );
};

sub test_truncated_comment {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<!--']);
    $self->handler->mock_expect_never('comment');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<!--',
    ) );
};

sub test_truncated_comment_no_close {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<!-- blah']);
    $self->handler->mock_expect_never('comment');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<!-- blah',
    ) );
};

1;
