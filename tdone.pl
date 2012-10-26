#!/usr/bin/perl 
use strict;
use warnings;
use Data::Dumper; sub D(@){ warn Dumper(@_) };
use Tie::File;
use v5.10;   

my @tasks;
tie @tasks, 'Tie::File', $ENV{TDONE_FILE} or die qq{TDONE_FILE not specified in env: $! $@};

my @actions = qw{add list done find edit};
my $action  = @ARGV == 0           ? 'list'
            : $ARGV[0] ~~ @actions ? shift
            :                        'add'
            ;

given ($action) {
  when ('list') { 
    my $fmt = sprintf qq{%% %ds: %%s\n}, length( scalar( @tasks ));
    my $i;
    printf $fmt, $i++, $_ for @tasks;
  }
  when ('add' ) { push @tasks, join ' ', @ARGV; }
  when ('done') { 
    delete $tasks[$_] for reverse sort @ARGV;
  }
  when ('find') { D {FIND => \@ARGV, TASKS => \@tasks}}
  when ('edit') { exec $ENV{VISUAL} || $ENV{EDITOR}, $ENV{TDONE_FILE}; }
  default       { qx{perldoc $0}   } # USEAGE
}

# sort
@tasks = grep{length} @tasks; # clean up any blank lines
# write
