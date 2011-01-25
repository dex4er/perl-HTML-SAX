#!/usr/bin/perl -c

package HTML::SAX::Locator;

=head1 NAME

HTML::SAX::Locator - Interface for HTML::SAX

=head1 SYNOPSIS

  package HTML::SAX;
  use Moose;
  with 'HTML::SAX::Locator';

=head1 DESCRIPTION

This role defined interface for L<HTML::SAX>.

=cut

use 5.006;

use strict;
use warnings;

our $VERSION = '0.01_01';

use Any::Moose 'Role';


=head1 REQUIRES

=over

=item get_public_id(I<>) : Str

Gets an identifier for this document.

=cut

requires 'get_public_id';


=item get_line_number(I<>) : Int

Gets a current line number.

=cut

requires 'get_line_number';


=item get_character_offset(I<>) : Int

Gets a current position of parsed rawtext.

=cut

requires 'get_character_offset';


=item get_raw_event_string(I<>) : Str

Gets a current character event string.

=back

=cut

requires 'get_raw_event_string';


1;


=begin umlwiki

= Class Diagram =

[             <<role>>
          HTML::SAX::Locator
 ------------------------------------
 <<requires>> +get_public_id()
 <<requires>> +get_line_number()
 <<requires>> +get_character_offset()
 <<requires>> +get_raw_event_string()
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

Copyright (c) 2009, 2011 Piotr Roszatycki E<lt>dexter@cpan.orgE<gt>.

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
