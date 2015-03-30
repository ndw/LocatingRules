package XML::Schema::LocatingRules::DocumentElement;

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

    #print STDERR "DocumentElement:\n";
    my $self = new XML::Schema::LocatingRules::Rule %attr;

    $self->type('documentElement');

    return bless $self, $type;
}

sub match {
    my $self = shift;
    my $lr = shift;
    my $info = shift;
    my $schema = undef;
    my $typeid = undef;

    if ($self->prefix() eq $info->prefix()
	&& $self->localName() eq $info->localName()) {
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
