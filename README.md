# LocatingRules

[nxml-mode](http://www.emacswiki.org/emacs/NxmlMode)
includes a configurable set of rules to locate a schema for the file
being edited. The rules are contained in one or more schema locating
files, which are XML documents.

LocatingRules is a Perl 5 module that implements the locating rules
search algorithm to find a schema.

It needs more documentation. See tests/test.pl for details.

Basically:

1. Construct a LocatingRules object.
2. Load some locating rules files.
   (If you call load(), the object will try to parse ~/.emacs for the files)
3. Setup a DocumentInfo object with details about the file.
4. Call schema() to find the schema file.

A DocumentScanner will build a DocumentInfo for you. By default it
does so with a few regular expressions (and may fail for some
encodings). Setting mode('parse') will cause it to parse the file, but
this means you'll end up parsing twice if you subsequently want to
validate.
