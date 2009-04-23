package HTML::SAX::ReaderCommentTest;

use Test::Unit::Lite;
use Moose;
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

1; __END__
/*
*   HTML 4.0:   Valid Markup see http://www.w3.org/MarkUp/SGML/sgml-lex/sgml-lex
*   XML 1.1:    Valid Markup
*/
sub testSimpleComment {
    $self->handler->mock_expect_once('comment', args => (' xyz '));
    $self->parser->parse('<!-- xyz -->');
}

/*
*   HTML 4.0:   Valid Markup 
*   XML 1.1:    Valid Markup
*/
sub testNastyComment {
    $self->handler->mock_expect_once(
            'comment',
            args => (' <tag></tag><?php ?><' . '% %> '));
    $self->handler->mock_expect_never('characters');
    $self->parser->parse('<tag><!-- <tag></tag><?php ?><' . '% %> --></tag>');
}

/*
*   XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
*/
sub testNotWellFormedComment {
    $self->handler->mock_expect_once('characters', args => ('<!-- B+, B, or B--->'));
    $self->handler->mock_expect_never('comment');
    $self->parser->parse('<!-- B+, B, or B--->');
}

/*
*   HTML 4.0:   Valid Markup see http://www.w3.org/MarkUp/SGML/sgml-lex/sgml-lex
*   XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
*/
sub testCompoundComment {
    $self->handler->mock_expect_once('comment', args => (args => (' xyz ', 'def')));
    $self->parser->parse('<!-- xyz -- --def-->');
}

/*
*   HTML 4.0:   Valid Markup see http://www.w3.org/MarkUp/SGML/sgml-lex/sgml-lex
*   XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
*/
sub testCompoundComment2 {
    $self->handler->mock_expect_once('comment', args => (args => ('', '', '')));
    $self->parser->parse('<!---- ---- ---->');
}

/*
*   HTML 4.0:   Valid Markup see http://www.w3.org/MarkUp/SGML/sgml-lex/sgml-lex
*   XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
*/
sub testCompoundComment3 {
    $self->handler->mock_expect_once('comment', args => (args => ('', '', '')));
    $self->parser->parse('<!------------>');
}

/*
*   HTML 4.0:   Invalid Markup see http://www.w3.org/MarkUp/SGML/sgml-lex/sgml-lex
*   XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
*/
sub testMalformedComment {
    $self->handler->mock_expect_once('characters', args => ('<!--x->'));
    $self->handler->mock_expect_never('comment');
    $self->parser->parse('<!--x->');
}

/*
*   HTML 4.0:   Invalid Markup see http://www.w3.org/MarkUp/SGML/sgml-lex/sgml-lex
*   XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
*/
sub testMalformedComment2 {
    $self->handler->mock_expect_once('characters', args => ('<!-- comment-- xxx>'));
    $self->handler->mock_expect_never('comment');
    $self->parser->parse('<!-- comment-- xxx>');
}

/*
*   HTML 4.0:   Invalid Markup see http://www.w3.org/MarkUp/SGML/sgml-lex/sgml-lex
*   XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
*/
sub testMalformedComment3 {
    $self->handler->mock_expect_once('characters', args => ('<!-- comment -- ->'));
    $self->handler->mock_expect_never('comment');
    $self->parser->parse('<!-- comment -- ->');
}

/*
*   HTML 4.0:   Invalid Markup see http://www.w3.org/MarkUp/SGML/sgml-lex/sgml-lex
*   XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
*/
sub testMalformedComment4 {
    $self->handler->mock_expect_once('characters', args => ('<!----->'));
    $self->handler->mock_expect_never('comment');
    $self->parser->parse('<!----->');
}

/*
*   HTML 4.0:   Valid markup 
*   XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
*
*   see http://www.hixie.ch/tests/adhoc/html/parsing/compat/008.html
*/
sub testCommentedTag {
    $self->handler->mock_expect_once('comment', args => ('><span><!'));
    $self->handler->mock_expect_never('startElement');
    $self->parser->parse('<!--><span><!-->');
}

/*
*   HTML 4.0:   Valid markup 
*   XML 1.1:    Not well-formed see http://www.w3.org/TR/xml11/#sec-comments
*
*   see http://www.hixie.ch/tests/adhoc/html/parsing/comments/001.html
*/
sub testNextedCommentConfusion {
    $self->handler->mock_expectArgumentsAt(0, 'comment', args => (args => ('', '><!')));
    $self->handler->mock_expectArgumentsAt(1, 'comment', args => (args => ('', '-><!')));
    $self->handler->mock_expectCallCount('comment', 2);
    $self->handler->mock_expect_once('characters', args => ('PASS'));
    $self->handler->mock_expect_never('startElement');
    $self->parser->parse('<!------><!-->PASS<!-------><!-->');
}

/*
*   HTML 4.0:   Invalid Markup
*   XML 1.1:    Not well-formed
*
*   see http://www.hixie.ch/tests/adhoc/html/parsing/comments/002.html
*/
sub testMalformedComment5 {
    $self->handler->mock_expect_once('characters', args => ('<!-- --FAIL>'));
    $self->handler->mock_expect_never('comment');
    $self->parser->parse('<!-- --FAIL>');
}

/*
*   HTML 4.0:   Invalid Markup
*   XML 1.1:    Not well-formed
*
*   see http://www.hixie.ch/tests/adhoc/html/parsing/comments/003.html
*/
sub testMalformedComment6 {
    $self->handler->mock_expect_once('characters', args => ('<!-- --- FAIL --- -->'));
    $self->handler->mock_expect_never('comment');
    $self->parser->parse('<!-- --- FAIL --- -->');
}

/*
*   HTML 4.0:   Valid Markup
*   XML 1.1:    Not well-formed
*
*   see http://www.hixie.ch/tests/evil/mixed/comments-evil.html    
*/
sub testCompoundComment7 {
    $self->handler->mock_expect_once('comment', args => (' ->incorrect<!- '));
    $self->handler->mock_expect_never('characters');
    $self->parser->parse('<!-- ->incorrect<!- -->');
}

/*
*   HTML 4.0:   Valid Markup
*   XML 1.1:    Not well-formed
*
*   see http://www.hixie.ch/tests/evil/mixed/comments-evil.html    
*/
sub testCompoundComment8 {
    $self->handler->mock_expect_once('comment', args => (args => (' ', '>incorrect<!', '')));
    $self->handler->mock_expect_never('characters');
    $self->parser->parse('<!-- ---->incorrect<!------>');
}

/*
*   HTML 4.0:   Valid Markup
*   XML 1.1:    Not well-formed
*
*   see http://www.hixie.ch/tests/evil/mixed/comments-evil.html    
*/
sub testCompoundComment9 {
    $self->handler->mock_expect_once('comment', args => (args => ('', '>incorrect<!', '')));
    $self->handler->mock_expect_never('characters');
    $self->parser->parse('<!------>incorrect<!------>');
}

/*
*   HTML 4.0:   Valid Markup
*   XML 1.1:    Not well-formed
*
*   see http://www.hixie.ch/tests/evil/mixed/comments-evil.html    
*/
sub testCompoundComment10 {
    $self->handler->mock_expect_once('comment', args => (args => ('', '>incorrect<!', '')));
    $self->handler->mock_expect_never('characters');
    $self->parser->parse('<!---- -->incorrect<!------>');
}

/*
*   HTML 4.0:   Valid Markup
*   XML 1.1:    Not well-formed
*
*   see http://www.hixie.ch/tests/evil/mixed/comments-evil.html    
*/
sub testCompoundComment11 {
    $self->handler->mock_expect_once('comment', args => (args => (' ', '>incorrect<!', ' ')));
    $self->handler->mock_expect_never('characters');
    $self->parser->parse('<!-- -- -->incorrect<!-- -- -->');
}

/*
*/
sub testTruncatedComment {
    $self->handler->mock_expect_once('characters', args => ('content<!--'));
    $self->handler->mock_expect_never('comment');
    $self->parser->parse('content<!--');
}

/*
*/
sub testTruncatedCommentNoClose {
    $self->handler->mock_expect_once('characters', args => ('content<!-- blah'));
    $self->handler->mock_expect_never('comment');
    $self->parser->parse('content<!-- blah');
}

1;
