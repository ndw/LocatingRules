package XML::Schema::LocatingRules::TransformURI;

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

    #print STDERR "TransformURI:\n";
    my $self = new XML::Schema::LocatingRules::Rule %attr;

    $self->type('transformURI');

    return bless $self, $type;
}

sub replacePathSuffix {
    my $self = shift;
    return $self->{'replacePathSuffix'};
}

sub pathSuffix {
    my $self = shift;
    return $self->{'pathSuffix'};
}

sub pathAppend {
    my $self = shift;
    return $self->{'pathAppend'};
}

sub match {
    my $self = shift;
    my $lr = shift;
    my $info = shift;
    my $schema = undef;

    if (defined $self->pathSuffix()) {
	my $suffix = $self->pathSuffix();
	my $uri = $info->uri();
	my $matches = 0;

	if (defined $suffix && defined $uri) {
	    if (substr($uri, length($uri)-length($suffix)) eq $suffix) {
		$matches = 1;
	    }
	}

	if (!$matches) {
	    print "Match: ", $self->type(), " (", $info->uri(), ") undef\n"
		if $self->debug() > 0;
	    return undef;
	}
    }

    if (defined $self->pathAppend()) {
	$schema = $info->uri() . $self->pathAppend();
    } elsif (defined $self->replacePathSuffix()) {
	my $suffix = $self->pathSuffix();
	my $uri = $info->uri();
	# we already know it matches
	$uri = substr($uri, 0, length($uri)-length($suffix));
	$schema = $uri . $self->replacePathSuffix();
    }

    if (defined $schema && -f $schema) {
	print "Match: ", $self->type(), " (", $info->uri(), ") $schema\n"
	     if $self->debug() > 0;
	return $schema;
    }

    print "Match: ", $self->type(), " (", $info->uri(), ") undef\n"
	 if $self->debug() > 0;
    return undef;
}

1;
