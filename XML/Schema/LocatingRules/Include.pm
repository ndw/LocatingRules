package XML::Schema::LocatingRules::Include;

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

    #print STDERR "Include:\n";
    my $self = new XML::Schema::LocatingRules::Rule %attr;

    $self->type('include');

    return bless $self, $type;
}

sub rules {
    my $self = shift;

    return $self->{'rules'};
}

1;
