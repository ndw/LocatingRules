package XML::Schema::LocatingRules::TypeIdProcessingInstruction;

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

    #print STDERR "TypeIdProcessingInstruction:\n";
    my $self = new XML::Schema::LocatingRules::Rule %attr;

    $self->type('typeIdProcessingInstruction');

    return bless $self, $type;
}

sub target {
    my $self = shift;
    return $self->{'target'};
}

sub match {
    my $self = shift;
    my $lr = shift;
    my $info = shift;
    my $typeid = undef;

    my @pis = $info->processingInstructions();

    while (@pis) {
	my $target = shift @pis;
	my $value = shift @pis;

	if ($self->target() eq $target) {
	    $typeid = $value;
	    last;
	}
    }

    if (defined $typeid) {
	my $schema = $lr->schemaForTypeId($typeid);
	print "Match: ", $self->type(), " typeId=$typeid $schema\n"
	    if $self->debug() > 0;
	return $schema;
    }

    print "Match: ", $self->type(), " undef\n" if $self->debug() > 0;
    return undef;
}

1;
