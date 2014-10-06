#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1 + 1;
use Test::NoWarnings;

BEGIN {
    use_ok( 'App::Devmode2' );
}

diag( "Testing App::Devmode2 $App::Devmode2::VERSION, Perl $], $^X" );
