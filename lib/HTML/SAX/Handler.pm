#!/usr/bin/perl -c

package HTML::SAX::Handler;

=head1 NAME

HTML::SAX::Handler - Interface for HTML::SAX handler

=head1 SYNOPSIS

  package My::Handler;
  use Moose;
  with 'HTML::Sax::Handler';
  sub start_document { ... };
  sub end_document { ... };
  sub characters { ... };
  sub start_element { ... };
  sub end_element { ... };
  sub empty_element { ... };
  sub cdata { ... };
  sub comment { ... };

  package main;
  my $handler = My::Handler->new;
  HTML::SAX->parse( rawtext => '<html></html>', handler => $handler );

=head1 DESCRIPTION

This role defines interface for L<HTML::SAX> handler. The L<HTML::SAX> parser
will call handler's methods if proper events will occur.

=cut

use 5.006;

use strict;
use warnings;

our $VERSION = '0.01_01';

use Moose::Role;


=head1 METHODS

=over

=item start_document( I<locator> : HTML::SAX::Locator, I<encoding> : Str )

Called on start of parsing.

=cut

sub start_document { };


=item end_document(I<>)

Called on end of parsing.

=cut

sub end_document { };


=item characters( I<data> : Str );

Called if some text was found.

=cut

sub characters { };


=item start_element( I<name> : Str, I<attrs> : Hash[Str] )

Called if empty element was found.

Examples:

    <a href="http://www.perl.org">

=cut

sub start_element { };


=item end_element( I<name> : Str )

Called if end element was found.

Examples:

    </a>

=cut

sub end_element { };


=item empty_element( I<name> : Str, I<attrs> : Hash[Str] )

Called if empty element was found.

Examples:

    <img src="http://st.pimg.net/tucs/img/cpan_banner.png" />

=cut

sub empty_element { };


=item cdata( I<data> : Str )

Called if CDATA was found.

Examples:

    <![CDATA[This is unparsed character data]]>

=cut

sub cdata { };


=item comment( I<data> : Array[Str] )

Called if comment was found.

Examples:

    <!-- This is comment -->

=back

=cut

sub comment { };


1;


=begin umlwiki

= Class Diagram =

[                         <<role>>
                      HTML::SAX::Handler
 ---------------------------------------------------------------
 +start_document( locator : HTML::SAX::Locator, encoding : Str )
 +end_document()
 +characters( data : Str );
 +start_element( name : Str, attrs : Hash[Str] )
 +end_element( name : Str )
 +empty_element( name : Str, attrs : Hash[Str] )
 +cdata( data : Str )
 +comment( data : Array[Str] )
                                                                 ]

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

Copyright (c) 2009 Piotr Roszatycki E<lt>dexter@cpan.orgE<gt>.

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
