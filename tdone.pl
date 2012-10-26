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

=head1 NAME 

  tdone : because the world really needs yet another 

=head2 USAGE

  tdone.pl [action] [task]

=head2 INSTALLL

=over

=item 1: Put tdone.pl some where in your PATH

=item 2: Touch a file and then set TDONE_FILE in your enviroment

=item 3: done =)

=back

=head2 VERBS

=over

=item B<list> : show a list of the file with added indexes (B<DEFAULT> action if no input is given)

=item B<add>  : add a new task to the file (B<DEFAULT> action if input is given but no action is given)

=item B<did>  : remove a task from the file, takes any number of id's from list

=item B<find> : search file for based on a given regular expression

=item B<edit> : open up the file in what ever your evniroment states as your prefered editor

=back

=head2 SYNTAX

=over

=item B<priority> is determined by the number of +'s at the start of a task.

=back

=head2 EXAMPES

  > tdone.pl list
  > tdone.pl add +++ some very important task @office :project
  > tdone.pl ++ some slightly important tast @office :meeting
  > tdone.pl get milk @store :food :grocieres 
  > tdone.pl list
  0: +++ some very important task @office :project
  1: ++ some slightly important tast @office :meeting
  2: get milk @store :food :grocieres
  > tdone.pl did 2 0
  > tdone.pl
  0: ++ some slightly important tast @office :meeting

  
