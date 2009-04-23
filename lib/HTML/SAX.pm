#!/usr/bin/perl -c

package HTML::SAX;

=head1 NAME

HTML::SAX - HTML/XHTML parser that outputs SAX events

=head1 SYNOPSIS

  use HTML::SAX;

=head1 DESCRIPTION

This class is designed primarily to parse HTML fragments.  Intended usage
scenarios include:

=over 2

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

our $VERSION = '0.01_01';

use Moose;

with 'HTML::SAX::Locator';


use English '-no_match_vars';


=head1 ATTRIBUTES

=over

=item public_id : Str

An identifier for this document

=cut

has 'public_id' => (
    isa     => 'Maybe[Str]',
    reader  => '_get_public_id',
    writer  => '_set_public_id',
    default => undef,
);

=item _handler : HTML::SAX::Handler

A class observing content events emited by this parser.

=cut

has 'handler' => (
    is     => 'rw',
    does   => 'HTML::SAX::Handler',
    reader => '_get_handler',
    writer => 'set_handler', ### TODO move to constructor
);

=item rawtext : Str

text document being parsed

=cut

has 'rawtext' => (
    isa     => 'Str',
    reader  => '_get_rawtext',
    writer  => '_set_rawtext',
    default => '',
);

=item _position : Int

Current position in document relative to start (0)

=cut

has '_position' => (
    isa     => 'Int',
    reader  => '_get_position',
    writer  => '_set_position',
    default => 0,
);

=item _char_start : Int

Current position of character

=cut

has '_char_start' => (
    isa     => 'Int',
    reader  => '_get_char_start',
    writer  => '_set_char_start',
    default => 0,
);

=item _markup_start : Int

Start position in document

=cut

has '_markup_start' => (
    isa     => 'Int',
    reader  => '_get_markup_start',
    writer  => '_set_markup_start',
    default => 0,
);

=item _length : Int

Length of the document in characters

=back

=cut

has '_length' => (
    isa     => 'Int',
    lazy    => 1,
    reader  => '_get_length',
    default => sub { length($_[0]->_get_rawtext) },
);


use namespace::clean -except => 'meta';


=head1 METHODS

=over

=item get_public_id(I<>) : Str

Gets an identifier for this document.

=cut

sub get_public_id {
    my ($self) = @_;
    return $self->_get_public_id;
};

=item get_line_number(I<>) : Int

Gets a current line number.

=cut

sub get_line_number {
    my ($self) = @_;
    return 1 + (substr($self->_get_rawtext, 0, $self->_get_position) =~ tr/\n//);
};


=item get_character_offset(I<>) : Int

Gets a current position of parsed rawtext.

=cut

sub get_character_offset {
    my ($self) = @_;
    return $self->_get_position;
};


=item get_raw_event_string(I<>) : Str

Gets a current character event string.

=cut

sub get_raw_event_string {
    my ($self) = @_;
    return substr($self->_get_rawtext, $self->_get_markup_start,
                  $self->_get_position - $self->_get_markup_start);
};


=item emit_characters(I<>) : Int

Emit characters event

=cut

sub emit_characters {
    my ($self) = @_;
    if ($self->_get_markup_start > $self->_get_char_start) {
        $self->_get_handler->characters(
            substr($self->_get_rawtext, $self->_get_char_start,
                   $self->_get_markup_start - $self->_get_char_start)
        );
    }
    $self->_set_char_start($self->_get_position);
};


=item parse( I<data> : Str, I<public_id> : Str = undef )

Begins the parsing operation, setting up any decorators, depending on parse
options invoking _parse() to execute parsing.  I<data> is a XML document to
parse.

=back

=cut

sub parse {
    my $self = shift;
    $self = __PACKAGE__->new(@_) if not blessed $self;

    $self->_get_handler->start_document($self, 'UTF-8');

    my $name_start_char = ':_a-zA-Z\xC0-\xD6\xD8-\xF6\xF8-\x{2FF}\x{370}-\x{37D}\x{37F}-\x{1FFF}\x{200C}-\x{200D}\x{2070}-\x{218F}\x{2C00}-\x{2FEF}\x{3001}-\x{D7FF}\x{F900}-\x{FDCF}\x{FDF0}-\x{FFFD}';
    my $name_char = $name_start_char . '-.0-9\x{b7}\x{0300}-\x{036f}\x{203f}-\x{2040}';

    my $name_pattern = '[' . $name_start_char . '][' . $name_char . ']*';

    my $markup_start_pattern = qr/(<\/|<!|<[$name_start_char])/;
    my $end_element_pattern = qr/\G($name_pattern)\s*>/;
    my $start_element_pattern = qr/\G($name_pattern)(?=\s|>|\/\s*>)/;
    my $start_element_end_pattern = qr/\G\s*(\/)?\s*>/;
    my $attribute_pattern = qr/\G\s*($name_pattern)(\s*=\s*("|\'|)(.*?)\3){0,1}(?=\s|\/>|>)/s;
    my $comment_pattern = qr/\G--(.*?)--\s*/s;
    my $comment_decl_end_pattern = qr/\G>/;

    my $cdata_pattern = qr/\G\[CDATA\[(.*)\]\]\>/s;

    my $rawtext = $self->_get_rawtext;

    LOOP: {
        do {
            pos($rawtext) = $self->_get_position;
            last unless $rawtext =~ /$markup_start_pattern/g;

            $self->_set_markup_start($LAST_MATCH_START[0]);
            $self->_set_position($LAST_MATCH_END[0]);

            if ($1 eq '</') {

                pos($rawtext) = $self->_get_position;
                redo unless $rawtext =~ /$end_element_pattern/;

                my $tag = $1;

                $self->_set_position( $LAST_MATCH_END[0] );
                $self->emit_characters;

                $self->_get_handler->end_element($tag);

            }
            elsif ($1 eq '<!') {

                pos($rawtext) = $self->_get_position;
                my @comments = ();
                while ($rawtext =~ /$comment_pattern/cg) {
                    push @comments, $1;
                };
                if (@comments) {
                    redo unless $rawtext =~ /$comment_decl_end_pattern/;
                    $self->_set_position( $LAST_MATCH_END[0] );
                    $self->emit_characters;
                    $self->_get_handler->comment(@comments);
                    redo;
                };

                pos($rawtext) = $self->_get_position;
                if ($rawtext =~ /$cdata_pattern/) {
                    my $cdata = $1;
                    $self->_set_position( $LAST_MATCH_END[0] );
                    $self->emit_characters;
                    $self->_get_handler->cdata($cdata);
                };

            }
            else {

                $self->_set_position( $self->_get_position - 1 );
                pos($rawtext) = $self->_get_position;
                redo unless $rawtext =~ /$start_element_pattern/;

                my $tag = $1;
                my @attributes = ();
                $self->_set_position( $LAST_MATCH_END[0] );

                pos($rawtext) = $self->_get_position;
                while ($rawtext =~ /$attribute_pattern/gc) {
                    my ($name, $value) = ($1, $4);
                    push @attributes, $name => $value;
#                    $self->_set_position( $LAST_MATCH_END[0] );
                };

#                pos($rawtext) = $self->_get_position;
                redo unless $rawtext =~ /$start_element_end_pattern/g;

                $self->_set_position( $LAST_MATCH_END[0] );
                $self->emit_characters;
                if (defined $1) {
                    $self->_get_handler->empty_element($tag, @attributes);
                } else {
                    $self->_get_handler->start_element($tag, @attributes);
                };

                # see http://www.w3.org/TR/REC-html40/appendix/notes.html#notes-specifying-data
                # for special handling issues with script and style tags
            };

        } while ($self->_get_position < $self->_get_length);
    }; # LOOP

    # emit any extra characters left on the end
    if ($self->_get_char_start < $self->_get_length) {
            $self->_get_handler->characters(substr($rawtext, $self->_get_char_start));
    };

    $self->_get_handler->end_document;
};


1;


=begin umlwiki

= Class Diagram =

[                 HTML::SAX
 ---------------------------------------------
 +public_id : Str
 +handler : HTML::SAX::Handler
 +rawtext : Str
 #_position : Int
 #_char_start : Int
 #_markup_start : Int
 #_length : Int
 ---------------------------------------------
 +get_public_id() : Str
 +get_line_number() : Int
 +get_character_offset() : Int
 +get_raw_event_string() : Str
 +emit_characters() : Int
 +parse( data : Str, public_id : Str = undef )
                                              ]


[HTML::SAX] ---|> <<role>> [HTML::SAX::Locator]

=end umlwiki

=head1 SEE ALSO

L<Moose>.

=for readme continue

=head1 BUGS

The API is not stable yet and can be changed in future.

=head1 AUTHOR

Piotr Roszatycki <dexter@cpan.org>

=head1 LICENSE

Copyright (c) 2006 Jeff Moore

Copyright (c) 2009 Piotr Roszatycki <dexter@cpan.org>.

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
