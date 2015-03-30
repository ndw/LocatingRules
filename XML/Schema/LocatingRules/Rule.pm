package XML::Schema::LocatingRules::Rule;

# Part of LocatingRules.
# Copyright (C) 2003 Norman Walsh, ndw@nwalsh.com.
# Version 0.5

use strict;

sub new {
    my $type = shift;
    my %attr = @_;

    my $self = {};
    $self->{'debug'} = 0;

    foreach my $key (keys %attr) {
	#print STDERR "\t$key=", $attr{$key},"\n";
	$self->{$key} = $attr{$key};
    }

    $self->{'_ruleType'} = 'none';

    return bless $self, $type;
}

sub debug {
    my $self = shift;
    my $debug = shift;

    $self->{'debug'} = $debug if defined $debug;
    return $self->{'debug'};
}

sub type {
    my $self = shift;
    my $type = shift;

    $self->{'_ruleType'} = $type if defined($type);

    return $self->{'_ruleType'};
}

sub uri {
    my $self = shift;
    return $self->{'uri'};
}

sub typeId {
    my $self = shift;
    return $self->{'typeId'};
}

sub localName {
    my $self = shift;
    return $self->{'localName'};
}

sub prefix {
    my $self = shift;
    return $self->{'prefix'};
}

sub match {
    my $self = shift;
    my $lr = shift;
    my $info = shift;

    print "Match: ", $self->type(), " undef\n" if $self->debug() > 0;
    return undef;
}

sub toString {
    my $self = shift;
    my $str = "";
    local $_;

    $str = sprintf("<%s", $self->type());
    foreach my $attr (keys %{$self}) {
	next if $attr =~ /^_/;
	$str .= sprintf(" %s=\"%s\"", $attr, $self->{$attr});
    }
    $str .= "/>";

    return $str;
}

1;
