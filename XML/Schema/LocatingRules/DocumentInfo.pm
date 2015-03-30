package XML::Schema::LocatingRules::DocumentInfo;

# Part of LocatingRules.
# Copyright (C) 2003 Norman Walsh, ndw@nwalsh.com.
# Version 0.5

use strict;
use vars qw(@ISA);
use File::Spec;

@ISA = ();

sub new {
    my $type = shift;

    my $self = {};

    $self->{'info'} = {};

    $self->{'info'}->{'uri'} = '';
    $self->{'info'}->{'publicId'} = '';
    $self->{'info'}->{'systemId'} = '';
    $self->{'info'}->{'namespace'} = '';
    $self->{'info'}->{'prefix'} = '';
    $self->{'info'}->{'localName'} = '';
    $self->{'info'}->{'root'} = '';
    $self->{'info'}->{'piTarget'} = [];
    $self->{'info'}->{'piData'} = [];

    return bless $self, $type;
}

sub showInfo {
    my $self = shift;

    print "DocumentInfo: ", $self->{'info'}->{'uri'}, "\n";
    foreach my $key (sort keys %{$self->{'info'}}) {
	next if $key =~ /^pi/;
	next if $key eq 'uri';
	print "\t$key: ", $self->{'info'}->{$key}, "\n";
    }

    for (my $count = 0; $count <= $#{$self->{'info'}->{'piTarget'}}; $count++) {
	my $target = $self->{'info'}->{'piTarget'}->[$count];
	my $data = $self->{'info'}->{'piData'}->[$count];
	print "\tPI: $target=$data\n";
    }
}

sub uri {
    my $self = shift;
    my $data = shift;

    if (defined $data) {
	if (! File::Spec->file_name_is_absolute($data)) {
	    $data = File::Spec->rel2abs($data);
	}
    }

    return $self->set('uri', $data);
}

sub publicId {
    my $self = shift;
    my $data = shift;
    return $self->set('publicId', $data);
}

sub systemId {
    my $self = shift;
    my $data = shift;
    return $self->set('systemId', $data);
}

sub namespace {
    my $self = shift;
    my $data = shift;
    return $self->set('namespace', $data);
}

sub localName {
    my $self = shift;
    my $data = shift;
    return $self->set('localName', $data);
}

sub prefix {
    my $self = shift;
    my $data = shift;
    return $self->set('prefix', $data);
}

sub root {
    my $self = shift;
    my $data = shift;

    if (defined $data) {
	if ($data =~ /^(.*?):(.*)$/) {
	    $self->prefix($1);
	    $self->localName($2);
	} else {
	    $self->prefix("");
	    $self->localName($data);
	}
    }

    return $self->set('root', $data);
}

sub processingInstruction {
    my $self = shift;
    my $target = shift;
    my $value = shift;

    push(@{$self->{'info'}->{'piTarget'}}, $target);
    push(@{$self->{'info'}->{'piData'}}, $value);
}

sub processingInstructions {
    my $self = shift;
    my @pis = ();

    for (my $count = 0; $count <= $#{$self->{'info'}->{'piTarget'}}; $count++) {
	push (@pis, $self->{'info'}->{'piTarget'}->[$count]);
	push (@pis, $self->{'info'}->{'piData'}->[$count]);
    }

    return @pis;
}

sub set {
    my $self = shift;
    my $field = shift;
    my $data = shift;

    $self->{'info'}->{$field} = $data if defined $data;
    return $self->{'info'}->{$field};
}

1;
