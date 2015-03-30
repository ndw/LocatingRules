package XML::Schema::LocatingRules::TypeId;

# Part of LocatingRules.
# Copyright (C) 2003 Norman Walsh, ndw@nwalsh.com.
# Version 0.5

use strict;
use vars qw(@ISA);
use XML::Schema::LocatingRules::Rule;

@ISA = qw(XML::Schema::LocatingRules::Rule);

sub new {
    my $type = shift;
    my %attr = @_;

    #print STDERR "TypeId:\n";
    my $self = new XML::Schema::LocatingRules::Rule %attr;

    $self->type('typeId');

    return bless $self, $type;
}

sub id {
    my $self = shift;
    return $self->{'id'};
}

sub match {
    my $self = shift;

    # These are handled specially by LocatingRules...
    return undef;
}

1;
