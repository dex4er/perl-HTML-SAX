package HTML::SAX::ReaderValidHtmlMarkupTest;

use Test::Unit::Lite;
use Moose;
extends 'Test::Unit::TestCase';

with 'HTML::SAX::HandlerTestRole';

use Test::Assert ':all';

use HTML::SAX;

# These cases are valid HTML Markup syntax, but they do not generate markup events
# in our SaxReader implementation
#
# SGML Short tag syntax
#
# Empty start-tag :
#   <UL>
#       <LI>  this is the first item of the list
#       <>  this is second one -- implied identifier is LI
#   </>
#
# Empty end-tag:
#   Some <B>bold text with empty end tag </> -- right here.
#
# Unclosed tags :
#   This text is <b<i> bold and italic at once </b</i>.
#
# Null-end tags :
#   <H1/Header with null-end tag/

sub test_empty_close {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['</>']);
    $self->handler->mock_expect_never('end_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '</>',
    ) );
};

1;
