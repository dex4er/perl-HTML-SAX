#!/usr/bin/perl -c

package HTML::SAX;

=head1 NAME

HTML::SAX - HTML/XHTML parser that outputs SAX events

=head1 SYNOPSIS

  use HTML::SAX;

=head1 DESCRIPTION

This class is designed primarily to parse HTML fragments.  Intended usage
scenarios include:

=over

=item *

A basis for santizing HTML strings

=item *

Recognizing XML style markup embedded in text documents

=item *

Implementing HTML-like markup languages

=back

This class emits events in a custom SAX API that is designed to represent HTML
documents as well as XML documents.  However, this class should be geared
primarly to HTML markup.

As a general strategy, markup events are emitted only for valid markup,
although sequence of events may not constitute a well-formed document.

There is no current definition of what is valid HTML markup and what is not.
(The HTML 4.0.1 spec claims a relationship to the SGML specification which is
not helpful for this application.)  The WHAT working group 
(http://whatwg.org/) is working on such a specification and this parser 
should track the parsing recommendations of that group as much as possible.

If potential markup is encountered that the parser does not understand, it is
passed through in the form of character data.

Entities are not parsed and instead passed through unaltered.  Character data
and attribute values may contain the <, &, and > characters.  Minimized
boolean attributes are allowed.  Attribute values without quotation marks are
allowed.  Comments are parsed SGML style

The text string to be parsed must be UTF-8.

=for readme stop

=cut

use 5.006;

use strict;
use warnings;

our $VERSION = '0.01';

use Moose;

with 'HTML::SAX::Locator';

=head1 ATTRIBUTES

=over

=item public_id

An identifier for this document

=cut

has 'public_id';

=item handler : HTML::SAX::Handler

A class observing content events emited by this parser.

=cut

has 'handler' => (
    is     => 'rw',
    does   => 'HTML::SAX::Handler',
    writer => 'set_handler',
);

=item rawtext : Str

text document being parsed

=cut

has 'rawtext' => (
    is  => 'ro',
    isa => 'Str',
);

=item position : Int

Current position in document relative to start (0)

=cut

has 'position' => (
    is  => 'ro',
    isa => 'Int',
);

has 'char_start';
has 'markup_start';

=back

=cut


use namespace::clean -except => 'meta';


## no critic (ProhibitBuiltinHomonyms)
## no critic (RequireArgUnpacking)
## no critic (RequireCheckingReturnValueOfEval)

=head1 METHODS

=over

=item get_line_number() : Int

=cut

sub get_line_number {
    my ($self) = @_;
    return 1 + (substr($self->rawtext, 0, $self->position) =~ tr/\n//);
};

=back

=cut


1;


=back

=begin umlwiki

= Class Diagram =

[HTML::SAX] ---|> <<role>> [HTML::SAX::Locator]

=end umlwiki

=head1 SEE ALSO

L<Moose>.

=head1 BUGS

The API is not stable yet and can be changed in future.

=for readme continue

=head1 AUTHOR

Piotr Roszatycki <dexter@cpan.org>

=head1 LICENSE

Copyright (c) 2006 Jeff Moore

Copyright (c) 2008, 2009 Piotr Roszatycki E<lt>dexter@cpan.orgE<gt>.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

See L<http://opensource.org/licenses/mit-license.php>
