package App::Devmode2;

# Created on: 2014-10-04 20:31:39
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use strict;
use warnings;
use Carp;
use Scalar::Util;
use List::Util;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;
use Getopt::Long;
use Pod::Usage;
use FindBin qw/$Bin/;
use Path::Class;
use base qw/Exporter/;

our $VERSION     = 0.1;
our @EXPORT_OK   = qw//;
our %EXPORT_TAGS = ();
my ($name)   = $PROGRAM_NAME =~ m{^.*/(.*?)$}mxs;

my %option = (
    out     => undef,
    verbose => 0,
    man     => 0,
    help    => 0,
    VERSION => 0,
);

sub run {
    my ($self) = @_;
    Getopt::Long::Configure('bundling');
    GetOptions(
        \%option,
        'layout|l=s',
        'verbose|v+',
        'man',
        'help',
        'VERSION!',
    ) or pod2usage(2);

    if ( $option{'VERSION'} ) {
        print "$name Version = $VERSION\n";
        return 1;
    }
    elsif ( $option{'man'} ) {
        pod2usage( -verbose => 2 );
        return 1;
    }
    elsif ( $option{'help'} ) {
        pod2usage( -verbose => 1 );
        return 1;
    }

    # do stuff here
    my $session  = @ARGV ? shift @ARGV : die "No session name passed!";
    my @sessions = $self->sessions();

    # set the terminal title to the session name
    $self->set_title($session);

    if ( grep { $_ eq $session } @sessions ) {
        # connect to session
        warn "found\n";
        return 1;
    }

    my @actions = ('-u2', 'new-session', '-s', $session, ';', 'source-file', "$ENV{HOME}/.tmux.conf");
    if ($option{layout}) {
        push @actions, ';', "source-file", "$ENV{HOME}/.tmux/layout/$option{layout}";
    }

    $self->_exec('tmux', @actions);
    warn "Not found\n";

    return 1;
}

sub set_title {
    my ($self, $session) = @_;
    eval { require Term::Title; } or return;
    Term::Title::set_titlebar($session);
    return;
}

sub sessions {
    my $self = shift;
    return map {
            /^(.+) : \s+ \d+ \s+ window/xms;
            $1;
        }
        $self->_qx('tmux ls');
}

sub _qx {
    my $self = shift;
    return qx/@_/;
}

sub _exec {
    my $self = shift;
    print join ' ', @_, "\n" if $option{verbose};
    exec @_ if !$option{test};
    return;
}

1;

__END__

=head1 NAME

App::Devmode2 - A tmux session loading tool

=head1 VERSION

This documentation refers to App::Devmode2 version HASH(0x1322de0)

=head1 SYNOPSIS

    devmode2 [options] <session>

  OPTIONS:
   <session>    A tmux session name to create or connect to
   -l --layout[=]str
                A layout to load if creating a new session

=head1 DESCRIPTION

C<devmode2> is a helper script for L<tmux> to simplify the creation and
management of sessions.

=head1 SUBROUTINES/METHODS

=head2 C<run ()>

Manage the logic to load sessions etc.

=head2 C<set_title ()>

Tries to set the terminal title to the session name (requires L<Term::Title>
to work).

=head2 C<sessions ()>

Gets a list of current tmux sessions.

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2014 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
