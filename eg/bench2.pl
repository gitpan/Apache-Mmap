#!/usr/bin/perl
##
## bench2.pl -- Simple benchmark using Apache::Mmap to get the 
## relative performance between:
##
##   * mapping two files and writing the contents to /dev/null
##   * opening a file then reading the contents and printing it to /dev/null
## 
## Mike Fletcher <lemur1@mindspring.com>
##

##
## $Id: bench2.pl,v 1.1 1997/08/26 04:10:45 fletch Exp fletch $
##

use strict;
use Carp;

use Apache::Mmap;
use Benchmark;

## Allow number of trials to be specified on command line
my $times = shift @ARGV || 5000; 

## Copy some files to /tmp to use.  Feel free to pick more 
## representative files.
unless( -r '/tmp/foo' and -r '/tmp/bar' ) {
  warn "Copying files to '/tmp/' to work with\n";
  system '/bin/cp', '/etc/services', '/tmp/foo';
  system '/bin/cp', '/etc/inetd.conf', '/tmp/bar';
}

## Open /dev/null to toss all output into
open( NULL, '>>/dev/null' )
  or croak "Can't open /dev/null: $!";

## Compare using mmap to open/print while(<FOO>)
timethese( $times, {
		   'Using Apache::Mmap on two files' => q!
		   my $ref = Apache::Mmap::mmap '/tmp/foo';
		   print NULL $$ref;
		   my $ref2 = Apache::Mmap::mmap '/tmp/bar';
		   print NULL $$ref2;
		   !,
		   'Using open/print while(<FOO>)' => q^
		   open( FOO, '/tmp/foo' ) or carp "Can't open /tmp/foo: $!";
		   print NULL while( <FOO> );
		   close( FOO );
		   ^ } );

close( NULL );

exit 0;

__END__
