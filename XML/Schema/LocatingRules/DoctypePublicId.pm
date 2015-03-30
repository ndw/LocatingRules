package XML::Schema::LocatingRules::DoctypePublicId;

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

    #print STDERR "DoctypePublicId:\n";
    my $self = new XML::Schema::LocatingRules::Rule %attr;

    $self->type('doctypePublicId');

    return bless $self, $type;
}

sub publicId {
    my $self = shift;
    return $self->{'publicId'};
}

sub match {
    my $self = shift;
    my $lr = shift;
    my $info = shift;
    my $schema = undef;
    my $typeid = undef;

    if (defined $info->publicId() && $self->publicId() eq $info->publicId()) {
	$schema = $self->uri();
	$typeid = $self->typeId();
    }

    if (defined $schema && -f $schema) {
	print "Match: ", $self->type(), " $schema\n" if $self->debug() > 0;
	return $schema;
    }

    if (defined $typeid) {
	$schema = $lr->schemaForTypeId($typeid);
	print "Match: ", $self->type(), " typeId=$typeid $schema\n"
	    if $self->debug() > 0;
	return $schema;
    }

    print "Match: ", $self->type(), " undef\n" if $self->debug() > 0;
    return undef;
}

1;
