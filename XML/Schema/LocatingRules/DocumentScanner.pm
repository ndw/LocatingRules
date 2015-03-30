package XML::Schema::LocatingRules::DocumentScanner;

# Part of LocatingRules.
# Copyright (C) 2003 Norman Walsh, ndw@nwalsh.com.
# Version 0.5

use strict;
use vars qw(@ISA);
use English;
use File::Spec;
use XML::Parser::PerlSAX;
use XML::Schema::LocatingRules::DocumentInfo;

@ISA = qw(XML::Schema::LocatingRules::DocumentInfo);

sub new {
    my $type = shift;
    my $self = new XML::Schema::LocatingRules::DocumentInfo;

    $self->{'scan'} = 1;
    $self->{'seenDoctype'} = 0;
    $self->{'mode'} = 'regex';
    $self->{'regexLimit'} = 4196;

    return bless $self, $type;
}

sub mode {
    my $self = shift;
    my $mode = shift;

    # mode=regex or mode=parse

    $self->{'mode'} = $mode if defined $mode;
    return $self->{'mode'};
}

sub regexLimit {
    my $self = shift;
    my $limit = shift;
    $self->{'regexLimit'} = $limit if defined $limit;
    return $self->{'regexLimit'};
}

sub scan {
    my $self = shift;
    my $file = shift;

    $self->uri($file);

    if ($self->mode() eq 'regex') {
	$self->regexParse($file);
    } else {
	my $parser = new XML::Parser::PerlSAX (Handler => $self);
	$parser->parse (Source => { 'SystemId' => $file });
    }
}

sub regexParse {
    my $self = shift;
    my $file = shift;
    local *F, $_;

    open (F, $file);
    read (F, $_, $self->{'regexLimit'});
    close (F);

    my $preamble = 1;
    while (1) {
	my $rest = "";

	if (/^\s*<!DOCTYPE[^>]+\[.*?\]\>/s || /^\s*<!DOCTYPE[^>]+>/s) {
	    $_ = $MATCH;
	    $rest = $POSTMATCH;
	    $preamble = 0;

	    if (/PUBLIC\s+([\"\'])(.*?)\1\s+([\"\'])(.*?)\3/s) {
		$self->publicId($2);
		$self->systemId($4);
	    } elsif (/SYSTEM\s+([\"\'])(.*?)\1/s) {
		$self->systemId($2);
	    } else {
		# neither
	    }
	} elsif (/^\s*<!--.*?-->/s) {
	    $_ = $MATCH;
	    $rest = $POSTMATCH;
	    # ignored
	} elsif (/^\s*<\?.*?\?>/s) {
	    $_ = $MATCH;
	    $rest = $POSTMATCH;

	    /\s*<\?(.*?)\s+(.*)\?>/;
	    my $target = $1;
	    my $data = $2;
	    $self->processingInstruction($target,$data) if $target !~ /^xml/i;
	} elsif (/^\s*(<.*?>)/s) {
	    $_ = $MATCH;
	    $rest = $POSTMATCH;

	    /\s*<([^>\s]+)/s;
	    $self->root($1);

	    my $xmlns = "xmlns";
	    if (/\s*<([^>\s:]+):/s) {
		$xmlns = "xmlns:$1";
	    }

	    if (/\s+$xmlns=([\"\'])(.*?)\1/s) {
		$self->namespace($2);
	    }

	    last;
	} else {
	    print STDERR "LocatingRules::DocumentScanner: Regex parse error ";
	    print STDERR "(" . $self->uri() . ")\n";
	    last;
	}

	$_ = $rest;
    }
}

sub doctype_decl {
    my $self = shift;
    my $decl = shift;

    $self->{'seenDoctype'} = 1;
    $self->publicId($decl->{'PublicId'});
    $self->systemId($decl->{'SystemId'});
}

sub start_document {
    my $self = shift;

    # nop;
}

sub end_document {
    my $self = shift;

    delete $self->{'scan'};
    delete $self->{'seenDoctype'};
}

sub start_element {
    my ($self, $element) = @_;

    return if !$self->{'scan'};
    $self->{'scan'} = 0;

    $self->root($element->{'Name'});

    my $prefix = '';
    my $localName = $element->{'Name'};

    if ($localName =~ /^(.*?):(.*)$/) {
	$prefix = $1;
	$localName = $2;
    }

    # Handle namespace decls
    foreach my $name (keys %{$element->{'Attributes'}}) {
	if ($name eq 'xmlns' || $name =~ /^xmlns:/) {
	    my $value = $element->{'Attributes'}->{$name};
	    $prefix = '';
	    $prefix = $1 if $name =~ /^(.*?):/;
	    $self->namespace($value) if $prefix eq $self->{'prefix'};
	}
    }
}

sub end_element {
    my ($self, $element) = @_;

    # nop;
}

sub characters {
    my ($self, $data) = @_;
    # nop;
}

sub processing_instruction {
    my ($self, $pi) = @_;

    return if $self->{'seenDoctype'};

    $self->processingInstruction($pi->{'Target'}, $pi->{'Data'});
}

sub comment {
    my ($self, $comment) = @_;
    # nop;
}

1;
