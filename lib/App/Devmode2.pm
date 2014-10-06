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
    my $session  = shift @ARGV // die "No session name passed!";
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

A full description of the module and its features.

May include numerous subsections (i.e., =head2, =head3, etc.).


=head1 SUBROUTINES/METHODS

A separate section listing the public components of the module's interface.

These normally consist of either subroutines that may be exported, or methods
that may be called on objects belonging to the classes that the module
provides.

Name the section accordingly.

In an object-oriented module, this section should begin with a sentence (of the
form "An object of this class represents ...") to give the reader a high-level
context to help them understand the methods that are subsequently described.


=head3 C<new ( $search, )>

Param: C<$search> - type (detail) - description

Return: App::Devmode2 -

Description:

=cut


=head1 DIAGNOSTICS

A list of every error and warning message that the module can generate (even
the ones that will "never happen"), with a full explanation of each problem,
one or more likely causes, and any suggested remedies.

=head1 CONFIGURATION AND ENVIRONMENT

A full explanation of any configuration system(s) used by the module, including
the names and locations of any configuration files, and the meaning of any
environment variables or properties that can be set. These descriptions must
also include details of any configuration language used.

=head1 DEPENDENCIES

A list of all of the other modules that this module relies upon, including any
restrictions on versions, and an indication of whether these required modules
are part of the standard Perl distribution, part of the module's distribution,
or must be installed separately.

=head1 INCOMPATIBILITIES

A list of any modules that this module cannot be used in conjunction with.
This may be due to name conflicts in the interface, or competition for system
or program resources, or due to internal limitations of Perl (for example, many
modules that use source code filters are mutually incompatible).

=head1 BUGS AND LIMITATIONS

A list of known problems with the module, together with some indication of
whether they are likely to be fixed in an upcoming release.

Also, a list of restrictions on the features the module does provide: data types
that cannot be handled, performance issues and the circumstances in which they
may arise, practical limitations on the size of data sets, special cases that
are not (yet) handled, etc.

The initial template usually just has:

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)
<Author name(s)>  (<contact address>)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2014 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
