#!/usr/bin/perl

use 5.008;
use strict;
use warnings;

use Test::Unit::Lite 0.11;
use Test::Assert;

use Exception::Base max_arg_nums => 0, max_arg_len => 200, verbosity => 4;
use Exception::Warning '%SIG' => 'die', verbosity => 4;
use Exception::Died '%SIG', verbosity => 4;
use Exception::Assertion verbosity => 4;

$ENV{ANY_MOOSE} = 'Moose';

local $SIG{__WARN__} = sub { require Carp; Carp::confess(@_) };

eval {
    require Moose;
};
if ($@) {
    print "1..0 # SKIP Moose required\n";
}
else {
    Test::Unit::HarnessUnit->new->start('Test::Unit::Lite::AllTests');
};
