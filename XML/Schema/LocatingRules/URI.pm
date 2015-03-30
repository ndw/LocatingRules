package XML::Schema::LocatingRules::URI;

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

    #print STDERR "URI: ", join(",", keys %attr), "\n";
    my $self = new XML::Schema::LocatingRules::Rule %attr;

    $self->type('uri');

    return bless $self, $type;
}

sub resource {
    my $self = shift;
    my $file = File::Spec->rel2abs($self->{'resource'});
    return $file;
}

sub pathSuffix {
    my $self = shift;
    return $self->{'pathSuffix'};
}

sub match {
    my $self = shift;
    my $lr = shift;
    my $info = shift;
    my $schema = undef;
    my $typeid = undef;

    #print STDERR "\nRSRC: ", $self->resource(), "\n";
    #print STDERR "SURI: ", $self->uri(), "\n";
    #print STDERR "IURI: ", $info->uri(), "\n";

    if (defined $self->resource()) {
	if (defined $info->uri() && $info->uri() eq $self->resource()) {
	    $schema = $self->uri();
	    $typeid = $self->typeId();
	}
    } else {
	my $suffix = $self->pathSuffix();
	my $uri = $info->uri();
	if (defined $suffix && defined $uri) {
	    if (substr($uri, length($uri)-length($suffix)) eq $suffix) {
		$schema = $self->uri();
		$typeid = $self->typeId();
	    }
	}
    }

    if (defined $schema && -f $schema) {
	print "Match: ", $self->type(), " (", $info->uri(), ") $schema\n"
	    if $self->debug() > 0;
	return $schema;
    }

    if (defined $typeid) {
	$schema = $lr->schemaForTypeId($typeid);
	print "Match: ", $self->type(), " (", $info->uri(), ") typeId=$typeid $schema\n"
	     if $self->debug() > 0;
	return $schema;
    }

    print "Match: ", $self->type(), " (", $info->uri(), ") undef\n"
	 if $self->debug() > 0;
    return undef;
}

1;
