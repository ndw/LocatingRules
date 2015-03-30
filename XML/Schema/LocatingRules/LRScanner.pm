package XML::Schema::LocatingRules::LRScanner;

# Part of LocatingRules.
# Copyright (C) 2003 Norman Walsh, ndw@nwalsh.com.
# Version 0.5

use File::Spec;
use XML::Schema::LocatingRules::TransformURI;
use XML::Schema::LocatingRules::TypeId;
use XML::Schema::LocatingRules::URI;
use XML::Schema::LocatingRules::Namespace;
use XML::Schema::LocatingRules::DocumentElement;
use XML::Schema::LocatingRules::Include;
use XML::Schema::LocatingRules::ApplyFollowingRules;
use XML::Schema::LocatingRules::DoctypePublicId;
use XML::Schema::LocatingRules::TypeIdBase;
use XML::Schema::LocatingRules::TypeIdProcessingInstruction;
use XML::Schema::LocatingRules::Default;

my $locatingRulesNS = "http://thaiopensource.com/ns/locating-rules/1.0";
my $DEBUG = 0;

sub new {
    my $type = shift;
    my $filename = shift;

    my $self = {};

    if (! File::Spec->file_name_is_absolute($filename)) {
	$filename = File::Spec->rel2abs($filename);
    }

    my ($volume, $path, $fn) = File::Spec->splitpath($filename);

    $self->{'prefixStack'} = [];
    $self->{'uriStack'} = [];
    $self->{'baseStack'} = [$path];
    $self->{'rules'} = [];

    return bless $self, $type;
}

sub rules {
    my $self = shift;
    return @{$self->{'rules'}};
}

sub start_document {
    my $self = shift;

    # nop;
}

sub end_document {
    my $self = shift;

    # nop;
}

sub start_element {
    my ($self, $element) = @_;

    push (@{$self->{'uriStack'}}, '---');
    push (@{$self->{'prefixStack'}}, '---');
    push (@{$self->{'baseStack'}}, '---');

    # Handle namespace decls and base URI
    foreach my $name (keys %{$element->{'Attributes'}}) {
	if ($name eq 'xmlns' || $name =~ /^xmlns:/) {
	    my $value = $element->{'Attributes'}->{$name};
	    $self->namespaceDecl($name, $value);
	}
	if ($name eq 'xml:base') {
	    my $value = $element->{'Attributes'}->{$name};
	    push(@{$self->{'baseStack'}}, $value);
	}
    }

    my $localName = $self->localName($element->{'Name'});
    my $nsURI = $self->namespaceURI($element->{'Name'});

    if ($nsURI eq $locatingRulesNS) {
	my %attr = ();

	foreach my $name (keys %{$element->{'Attributes'}}) {
	    next if ($name eq 'xmlns' || $name =~ /^xmlns:/);
	    next if $name eq 'xml:base';
	    my $value = $element->{'Attributes'}->{$name};
	    $value = $self->absURI($value) if $name eq 'uri';
	    $attr{$name} = $value;
	}

	my $rule = undef;

	if ($localName eq 'locatingRules') {
	    # nop;
	} elsif ($localName eq 'transformURI') {
	    $rule = new XML::Schema::LocatingRules::TransformURI %attr;
	} elsif ($localName eq 'uri') {
	    $rule = new XML::Schema::LocatingRules::URI %attr;
	} elsif ($localName eq 'namespace') {
	    $rule = new XML::Schema::LocatingRules::Namespace %attr;
	} elsif ($localName eq 'documentElement') {
	    $rule = new XML::Schema::LocatingRules::DocumentElement %attr;
	} elsif ($localName eq 'typeId') {
	    $rule = new XML::Schema::LocatingRules::TypeId %attr;
	} elsif ($localName eq 'applyFollowingRules') {
	    $rule = new XML::Schema::LocatingRules::ApplyFollowingRules %attr;
	} elsif ($localName eq 'include') {
	    $attr{'rules'} = $self->absURI($attr{'rules'});
	    $rule = new XML::Schema::LocatingRules::Include %attr;
	} elsif ($localName eq 'typeIdBase') {
	    $attr{'_baseURI'} = $self->baseURI();
	    $rule = new XML::Schema::LocatingRules::TypeIdBase %attr;
	} elsif ($localName eq 'typeIdProcessingInstruction') {
	    $rule = new XML::Schema::LocatingRules::TypeIdProcessingInstruction %attr;
	} elsif ($localName eq 'doctypePublicId') {
	    $rule = new XML::Schema::LocatingRules::DoctypePublicId %attr;
	} elsif ($localName eq 'default') {
	    $rule = new XML::Schema::LocatingRules::Default %attr;
	} else {
	    # unrecognized!
	}

	if (defined $rule) {
	    $rule->debug($DEBUG);
	    push(@{$self->{'rules'}}, $rule);
	}
    }
}

sub end_element {
    my ($self, $element) = @_;
    local $_;

    while (1) {
	last if !@{$self->{'uriStack'}};
	my $mark = pop(@{$self->{'uriStack'}});
	$mark = pop(@{$self->{'prefixStack'}});
	last if $mark eq '---';
    }

    $_ = pop(@{$self->{'baseStack'}});
    while ($_ ne '---') {
	$_ = pop(@{$self->{'baseStack'}});
    }
}

sub characters {
    my ($self, $data) = @_;
    # nop;
}

sub processing_instruction {
    my ($self, $pi) = @_;
    # nop;
}

sub comment {
    my ($self, $comment) = @_;
    # nop;
}

sub namespaceDecl {
    my $self = shift;
    my $xmlns = shift;
    my $nsuri = shift;

    my $prefix = "";
    $prefix = $1 if $xmlns =~ /^.*:(.*)$/;

    push (@{$self->{'prefixStack'}}, $prefix);
    push (@{$self->{'uriStack'}}, $nsuri);
}

sub namespaceURI {
    my $self = shift;
    my $name = shift;
    my $pos = $#{$self->{'uriStack'}};

    my $prefix = "";
    $prefix = $1 if $name =~ /^(.*?):/;

    while ($pos >= 0) {
	my $pfx = $self->{'prefixStack'}->[$pos];
	my $uri = $self->{'uriStack'}->[$pos];
	return $uri if $pfx eq $prefix;
	$pos--;
    }

    return "";
}

sub localName {
    my $self = shift;
    my $name = shift;

    my $lname = $name;
    $lname = $1 if $name =~ /^.*?:(.*)$/;

    return $lname;
}

sub _transformURI {
    my $self = shift;
    my $pathAppend = shift;
    my $pathSuffix = shift;
    my $replacePathSuffix = shift;

    my $filename = $self->{'filename'};
    my $schema = "";

    if ($pathSuffix) {
	if ($filename =~ /^(.*)$pathSuffix$/) {
	    if ($replacePathSuffix) {
		$schema = $1 . $replacePathSuffix;
	    } elsif ($pathAppend) {
		$schema = $filename . $pathAppend;
	    }
	}
    } else {
	if ($pathAppend) {
	    $schema = $filename . $pathAppend;
	}
    }

    #print "TRANSFORM: $schema\n" if $schema ne '';
    $self->{'schema'} = $schema if $schema ne '' && -f $schema;
}

sub _uri {
    my $self = shift;
    my $resource = shift;
    my $uri = shift;
    my $pathSuffix = shift;
    my $typeId = shift;

    my $filename = $self->{'filename'};
    my $schema = "";
    my $type = "";

    if ($pathSuffix && $filename =~ /$pathSuffix$/) {
	$schema = $uri;
	$type = $typeId;
    } elsif ($resource eq $filename) {
	$schema = $uri;
	$type = $typeId;
    }

    #print "URI: $schema ($type)\n" if $schema ne '' || $type ne '';

    if ($schema ne '') {
	$schema = $self->absolute($self->{'locatingRules'}, $schema);
	$self->{'schema'} = $schema if -f $schema;
    } elsif ($type ne '') {
	$self->{'typeId'} = $type;
    }
}

sub _namespace {
    my $self = shift;
    my $ns = shift;
    my $uri = shift;
    my $typeId = shift;

    my $schema = "";
    my $type = "";

    if ($ns eq $self->{'namespace'}) {
	$schema = $uri;
	$type = $typeId;
    }

    #print "NS: $schema ($type)\n" if $schema ne '' || $type ne '';

    if ($schema ne '') {
	$schema = $self->absolute($self->{'locatingRules'}, $schema);
	$self->{'schema'} = $schema if -f $schema;
    } elsif ($type ne '') {
	$self->{'typeId'} = $type;
    }
}

sub _documentElement {
    my $self = shift;
    my $prefix = shift;
    my $localName = shift;
    my $uri = shift;
    my $typeId = shift;

    my $schema = "";
    my $type = "";

    my $rootLocal = $self->localName($self->{'root'});
    my $rootPrefix = "";
    $rootPrefix = $1 if $self->{'root'} =~ /^(.*?):/;

    $rootPrefix = "" if $prefix eq '';
    $rootLocal = "" if $localName eq '';

    if ($rootPrefix eq $prefix && $rootLocal eq $localName) {
	$schema = $uri;
	$type = $typeId;
    }

    #print "DE: $schema ($type)\n" if $schema ne '' || $type ne '';

    if ($schema ne '') {
	$schema = $self->absolute($self->{'locatingRules'}, $schema);
	$self->{'schema'} = $schema if -f $schema;
    } elsif ($type ne '') {
	$self->{'typeId'} = $type;
    }
}

sub _typeId {
    my $self = shift;
    my $id = shift;
    my $uri = shift;
    my $typeId = shift;

    #print "TYPEID: $id, $uri, $typeId\n";

    my @stats = ($id, $uri, $typeId);

    $self->{'typeIds'} = () if !defined($self->{'typeIds'});
    push (@{$self->{'typeIds'}}, \@stats);
}

sub absolute {
    my $self = shift;
    my $base = shift;
    my $file = shift;

    return $file if $file =~ /^\//;

    $base =~ s/\/[^\/]+$//;

    return "$base/$file";
}

sub baseURI {
    my $self = shift;

    for (my $count = $#{$self->{'baseStack'}}; $count >= 0; $count--) {
	my $base = $self->{'baseStack'}->[$count];
	return $base if $base ne '---';
    }
}

sub absURI {
    my $self = shift;
    my $file = shift;
    my $base = $self->baseURI();

    return File::Spec->rel2abs($file, $base);
}

sub debug {
    my $self = shift;
    my $debug = shift;

    $DEBUG = $debug if defined $debug;
    return $DEBUG;
}

1;
