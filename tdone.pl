#!/usr/bin/perl 
use strict;
use warnings;
use Data::Dumper; sub D(@){ warn Dumper(@_) };
use Tie::File;
use v5.10;   

my @tasks;
tie @tasks, 'Tie::File', $ENV{TDONE_FILE} or die qq{TDONE_FILE not specified in env: $! $@};

sub LIST {
  my $fmt = sprintf qq{%% %ds: %%s\n}, length( scalar( @tasks ));
  my $i;
  map{sprintf $fmt, $i++, $_} @tasks;
}

my @actions = qw{add list did find edit};
my $action  = @ARGV == 0           ? 'list'
            : $ARGV[0] ~~ @actions ? shift
            :                        'add'
            ;

given ($action) {
  when ('list') { print LIST }
  when ('add' ) { push @tasks, join ' ', @ARGV; }
  when ('did' ) { delete $tasks[$_] for reverse sort @ARGV; }
  when ('find') { my $match = shift @ARGV; print grep{/$match/} LIST }
  when ('edit') { exec $ENV{VISUAL} || $ENV{EDITOR}, $ENV{TDONE_FILE}; }
  default       { qx{perldoc $0}   } # USAGE
}


# float more +'s up to the top as a marker for priority
@tasks = sort{ my ($x)=$a=~m/^([+]*)/; my($y)=$b=~m/^([+]*)/; length($y)<=>length($x)} @tasks;

# clean up any blank lines
@tasks = grep{length} @tasks; 

# write happens when goes out of scope
