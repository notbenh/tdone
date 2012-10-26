#!/usr/bin/perl 
use strict;
use warnings;
use Data::Dumper; sub D(@){ warn Dumper(@_) };
use Tie::File;
use v5.10;   

tie my @tasks, 'Tie::File', $ENV{TDONE_FILE} || <main::DATA>; # ? or die?

my @actions = qw{add list done find};
my $action  = @ARGV == 0           ? 'list'
            : $ARGV[0] ~~ @actions ? shift
            :                        'add'
            ;

given ($action) {
  when ('list') { D {LIST => \@ARGV}}
  when ('add' ) { D {ADD  => \@ARGV}}
  when ('done') { D {DONE => \@ARGV}}
  when ('find') { D {FIND => \@ARGV}}
  default       { qx{perldoc $0}   } # USEAGE
}
__END__
finish this thing @laptop
