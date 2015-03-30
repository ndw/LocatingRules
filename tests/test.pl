#!/usr/bin/perl -- # -*- Perl -*-

BEGIN { $| = 1; print "1..14\n"; }          # THERE ARE 14 TESTS
END {print "not ok 1\n" unless $loaded;}

use strict;
use vars qw($loaded);
use lib '/projects/src/LocatingRules';
use XML::Schema::LocatingRules;
use XML::Schema::LocatingRules::DocumentInfo;
use XML::Schema::LocatingRules::DocumentScanner;
use File::Spec;

$loaded = 1;
print "ok 1\n";

my $DEBUG = 0;

my $script = $0;
if (! File::Spec->file_name_is_absolute($script)) {
    $script = File::Spec->rel2abs($script);
}

my ($volume, $path, $file) = File::Spec->splitpath($script);

my $lr = new XML::Schema::LocatingRules;
$lr->debug($DEBUG) if $DEBUG > 1;
$lr->load("${path}simple.xml");

my $TESTNUMBER = 2;

# ----------------------------------------------------------------------

my $di = new XML::Schema::LocatingRules::DocumentScanner;
$di->mode('regex');
$di->scan("${path}test1.xml");
my @pis = $di->processingInstructions();
print "not " if ($di->publicId() ne '-//Test//DTD Test//EN'
		 || $di->systemId() ne 'test.dtd'
		 || $di->root() ne 't:test'
		 || $di->prefix() ne 't'
		 || $di->localName() ne 'test'
 		 || $di->namespace() ne 'http://example.com/xmlns/test'
		 || $#pis != 1
		 || $pis[0] != 'my-doctype'
		 || $pis[1] != 'None');
print "ok ", $TESTNUMBER++, "\n";

# ----------------------------------------------------------------------

$di = new XML::Schema::LocatingRules::DocumentScanner;
$di->mode('regex');
$di->scan("${path}test2.xml");
@pis = $di->processingInstructions();
print "not " if ($di->publicId() ne ''
		 || $di->systemId() ne 'test.dtd'
		 || $di->root() ne 'test'
		 || $di->prefix() ne ''
		 || $di->localName() ne 'test'
 		 || $di->namespace() ne 'http://example.com/xmlns/test'
		 || $#pis != 1
		 || $pis[0] != 'my-doctype'
		 || $pis[1] != 'None');
print "ok ", $TESTNUMBER++, "\n";

# ----------------------------------------------------------------------

$di = new XML::Schema::LocatingRules::DocumentScanner;
$di->mode('regex');
$di->scan("${path}test3.xml");
@pis = $di->processingInstructions();
print "not " if ($di->publicId() ne ''
		 || $di->systemId() ne ''
		 || $di->root() ne 'test'
		 || $di->prefix() ne ''
		 || $di->localName() ne 'test'
 		 || $di->namespace() ne 'http://example.com/xmlns/test'
		 || $#pis != -1);
print "ok ", $TESTNUMBER++, "\n";

# ----------------------------------------------------------------------

$di = new XML::Schema::LocatingRules::DocumentScanner;
$di->mode('regex');
$di->scan("${path}test3.xml");
@pis = $di->processingInstructions();
print "not " if ($di->publicId() ne ''
		 || $di->systemId() ne ''
		 || $di->root() ne 'test'
		 || $di->prefix() ne ''
		 || $di->localName() ne 'test'
 		 || $di->namespace() ne 'http://example.com/xmlns/test'
		 || $#pis != -1);
print "ok ", $TESTNUMBER++, "\n";

# ----------------------------------------------------------------------

$di = new XML::Schema::LocatingRules::DocumentScanner;
$di->mode('regex');
$di->scan("${path}test4.xml");
@pis = $di->processingInstructions();
print "not " if ($di->publicId() ne ''
		 || $di->systemId() ne ''
		 || $di->root() ne 'test'
		 || $di->prefix() ne ''
		 || $di->localName() ne 'test'
 		 || $di->namespace() ne ''
		 || $#pis != -1);
print "ok ", $TESTNUMBER++, "\n";

# ----------------------------------------------------------------------

my $answer = "${path}rnc/docbook.rnc";
$di = new XML::Schema::LocatingRules::DocumentInfo;
$di->processingInstruction('my-doctype', 'DocBook');
$di->uri('test.xml');
my $schema = $lr->schema($di);

print "\t$answer\n" if $DEBUG;
print "\t$schema\n" if $DEBUG;

print "not " if $schema ne $answer;
print "ok ", $TESTNUMBER++, "\n";

# ----------------------------------------------------------------------

$answer = "${path}Website.rnc";
$di = new XML::Schema::LocatingRules::DocumentInfo;
$di->uri('test.xml');
$di->root('webpage');
my $schema = $lr->schema($di);

print "\t$answer\n" if $DEBUG;
print "\t$schema\n" if $DEBUG;

print "not " if $schema ne $answer;
print "ok ", $TESTNUMBER++, "\n";

# ----------------------------------------------------------------------

$answer = "${path}rnc/docbook.rnc";
$di = new XML::Schema::LocatingRules::DocumentInfo;
$di->uri('test.xml');
$di->publicId('-//OASIS//DTD DocBook XML V4.3//EN');
my $schema = $lr->schema($di);

print "\t$answer\n" if $DEBUG;
print "\t$schema\n" if $DEBUG;

print "not " if $schema ne $answer;
print "ok ", $TESTNUMBER++, "\n";

# ----------------------------------------------------------------------

$answer = "${path}rnc/docbook.rnc";
$di = new XML::Schema::LocatingRules::DocumentInfo;
$di->uri('test.xml');
$di->root('book');
my $schema = $lr->schema($di);

print "\t$answer\n" if $DEBUG;
print "\t$schema\n" if $DEBUG;

print "not " if $schema ne $answer;
print "ok ", $TESTNUMBER++, "\n";

# ----------------------------------------------------------------------

$lr = new XML::Schema::LocatingRules;
$lr->debug($DEBUG) if $DEBUG > 1;
$lr->load("${path}schemas.xml");

# ----------------------------------------------------------------------

$answer = "${path}rnc/xslt.rnc";
$di = new XML::Schema::LocatingRules::DocumentInfo;
$di->uri("${path}rnc/xslt.xml");
my $schema = $lr->schema($di);

print "\t$answer\n" if $DEBUG;
print "\t$schema\n" if $DEBUG;

print "not " if $schema ne $answer;
print "ok ", $TESTNUMBER++, "\n";

# ----------------------------------------------------------------------

$answer = "${path}rnc/rdfxml.rnc";
$di = new XML::Schema::LocatingRules::DocumentInfo;
$di->uri("test.rdf");
my $schema = $lr->schema($di);

print "\t$answer\n" if $DEBUG;
print "\t$schema\n" if $DEBUG;

print "not " if $schema ne $answer;
print "ok ", $TESTNUMBER++, "\n";

# ----------------------------------------------------------------------

$answer = "${path}rnc/xslt.rnc";
$di = new XML::Schema::LocatingRules::DocumentInfo;
$di->uri("test");
$di->root('stylesheet');

my $schema = $lr->schema($di);

print "\t$answer\n" if $DEBUG;
print "\t$schema\n" if $DEBUG;

print "not " if $schema ne $answer;
print "ok ", $TESTNUMBER++, "\n";

# ----------------------------------------------------------------------

$answer = "${path}rnc/xslt.rnc";
$di = new XML::Schema::LocatingRules::DocumentInfo;
$di->uri("test");
$di->root('xsl:transform');

my $schema = $lr->schema($di);

print "\t$answer\n" if $DEBUG;
print "\t$schema\n" if $DEBUG;

print "not " if $schema ne $answer;
print "ok ", $TESTNUMBER++, "\n";
