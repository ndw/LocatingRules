package XML::Schema::LocatingRules::ApplyFollowingRules;

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

    #print STDERR "ApplyFollowingRules:\n";
    my $self = new XML::Schema::LocatingRules::Rule %attr;

    $self->type('applyFollowingRules');

    return bless $self, $type;
}

sub ruleType {
    my $self = shift;
    return $self->{'ruleType'};
}

1;
