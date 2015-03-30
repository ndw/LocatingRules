package XML::Schema::LocatingRules;

use strict;
use vars qw($VERSION @ISA @EXPORT);
use Text::DelimMatch;
use XML::Parser::PerlSAX;
use XML::Schema::LocatingRules::LRScanner;
use XML::Schema::LocatingRules::DocumentInfo;

require 5.000;
require Exporter;
require AutoLoader;

@ISA = qw(Exporter AutoLoader);
@EXPORT = qw();
$VERSION = '0.5';

my $DEBUG = 0;

sub new {
    my $type = shift;
    my $self = {};

    $self->{'rules'} = [];
    $self->{'info'} = new XML::Schema::LocatingRules::DocumentInfo;

    return bless $self, $type;
}

sub load {
    my $self = shift;
    my @files = @_;
    my @rules = ();

    @files = $self->schemaLocatingFiles(".emacs") if !@files;

    foreach my $file (@files) {
	my $absFile = File::Spec->rel2abs($file);
	next if ! -f $absFile;
	push (@{$self->{'rules'}}, $self->loadFile($absFile));
    }

    $self->fixupApplyFollowingRules();
}

sub schema {
    my $self = shift;
    my $root = shift;
    my $namespace = shift;
    my $publicId = shift;
    my $docInfo = undef;

    if (ref $root) {
	# assumed to be a DocumentInfo
	$docInfo = $root;
    } else {
	$docInfo = $self->{'info'};
	$docInfo->publicId($publicId) if defined $publicId;
	$docInfo->namespace($namespace) if defined $namespace;
	$docInfo->root($root) if defined $root;
    }

    foreach my $rule (@{$self->{'rules'}}) {
	my $match = $rule->match($self, $docInfo);
	return $match if defined $match;
    }

    return undef;
}

# ======================================================================

sub loadFile {
    my $self = shift;
    my $file = shift;
    my @rules = ();

    print "LocatingRules: loading $file\n" if $self->debug() > 1;

    my $handler = new XML::Schema::LocatingRules::LRScanner($file);
    $handler->debug($DEBUG);

    my $parser = new XML::Parser::PerlSAX (Handler => $handler);
    $parser->parse (Source => { 'SystemId' => $file });

    foreach my $rule ($handler->rules()) {
	if (ref $rule eq 'XML::Schema::LocatingRules::Include') {
	    push (@rules, $self->loadFile($rule->rules()));
	} else {
	    push (@rules, $rule);
	}
    }

    return @rules;
}

sub schemaLocatingFiles {
    my $self = shift;
    my $dotName = shift;
    my $dotEmacs = $ENV{'HOME'} . "/$dotName";
    my @files = ();
    local $_;

    open (F, $dotEmacs);
    read (F, $_, -s $dotEmacs);
    close (F);

    if (/rng-schema-locating-files\s/) {
	# discard everything that comes before it.
	s/^.*?rng-schema-locating-files//sg;

	my $mc = new Text::DelimMatch '\(', '\)';
	my ($prefix, $match, $remainder);
	$mc->quote('"');
	$mc->escape("\\");

	($prefix, $_, $remainder) = $mc->match($_);

	$mc = new Text::DelimMatch '"';
	$mc->returndelim(0);

	while ($_ ne '') {
	    ($prefix, $match, $remainder) = $mc->match($_);
	    push (@files, $match) if $match ne '';
	    $_ = $remainder;
	}
    }

    return @files;
}

sub fixupApplyFollowingRules {
    my $self = shift;
    my @rules = ();

    for (my $count = 0; $count <= $#{$self->{'rules'}}; $count++) {
	my $rule = $self->{'rules'}->[$count];
	if ($rule->type eq 'applyFollowingRules') {
	    if ($rule->ruleType() ne 'applyFollowingRules') {
		for (my $aCount = $count+1; $aCount <= $#{$self->{'rules'}}; $aCount++) {
		    my $fRule = $self->{'rules'}->[$aCount];
		    if ($fRule->type() eq $rule->ruleType()) {
			push (@rules, $fRule);
		    }
		}
	    }
	} else {
	    push (@rules, $rule);
	}
    }

    @{$self->{'rules'}} = @rules;
}

sub schemaForTypeId {
    my $self = shift;
    my $typeid = shift;

    foreach my $rule (@{$self->{'rules'}}) {
	if ($rule->type() eq 'typeId') {
	    next if $rule->id() ne $typeid;

	    if ($rule->typeId()) {
		return $self->schemaForTypeId($rule->typeId());
	    } else {
		return $rule->uri() if -f $rule->uri();
	    }
	} elsif ($rule->type() eq 'typeIdBase') {
	    my $uri = $rule->{'_baseURI'};
	    $uri .= "/" if $uri !~ /\/$/;
	    $uri .= $typeid;
	    $uri .= $rule->{'append'};
	    return $uri if -f $uri;
	} else {
	    # nop;
	}
    }

    return undef;
}


sub showRules {
    my $self = shift;

    foreach my $rule (@{$self->{'rules'}}) {
	print $rule->toString(), "\n";
    }
}

sub debug {
    my $self = shift;
    my $debug = shift;

    $DEBUG = $debug if defined $debug;
    return $DEBUG;
}

# ======================================================================

sub uri {
    my $self = shift;
    return $self->{'info'}->uri(@_);
}

sub publicId {
    my $self = shift;
    return $self->{'info'}->publicId(@_);
}

sub systemId {
    my $self = shift;
    return $self->{'info'}->systemId(@_);
}

sub namespace {
    my $self = shift;
    return $self->{'info'}->namespace(@_);
}

sub localName {
    my $self = shift;
    return $self->{'info'}->localName(@_);
}

sub prefix {
    my $self = shift;
    return $self->{'info'}->prefix(@_);
}

sub root {
    my $self = shift;
    return $self->{'info'}->root(@_);
}

sub processingInstruction {
    my $self = shift;
    return $self->{'info'}->processingInstruction(@_);
}

sub processingInstructions {
    my $self = shift;
    return $self->{'info'}->processingInstructions(@_);
}

1;
