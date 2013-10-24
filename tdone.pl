#!/usr/bin/env perl 
use strict;
use warnings;
use Tie::File;
use Term::ANSIColor qw(:constants);
use Scalar::Util qw{looks_like_number};
use v5.10;
no if $] >= 5.018, 'warnings', map{qq{experimental::$_}} qw{smartmatch};
my $VERSION = 2.0;

my @tasks;
tie @tasks, 'Tie::File', $ENV{TDONE_FILE} or die qq{TDONE_FILE not specified in env: $! $@};

sub LIST {
  my $BW  = BOLD WHITE;
  my $ID  = BRIGHT_BLACK;
  my $PRI = BOLD BRIGHT_RED;
  my $LOC = BOLD WHITE;
  my $TAG = BRIGHT_GREEN;
  my $R  = RESET;
  my $fmt = sprintf qq{$ID%% %ds:$R %%s\n}, length( scalar( @tasks ));
  my $i;
  map{ my $task = $_; # pull copy for display
       $task =~ s/^([+]*)/$PRI$1$R/;
       $task =~ s/([@]\w+)/$LOC$1$R/g;
       $task =~ s/([:]\w+)/$TAG$1$R/g;
       sprintf $fmt, $i++, $task
     } @tasks;
}

sub FIND {
  my $match = join ' ', @_;
  return grep{/$match/} LIST 
}

my $actions = { 
    list => sub{ print LIST}
  , add  => sub{ push @tasks, join ' ', @_}
  , did  => sub{ delete $tasks[$_] for reverse sort grep{looks_like_number $_} @_; } # do in bottom up as to not bother the ordering
  , at   => sub{ print FIND(sprintf q{\@%s\b}, $_[0]); }
  , tag  => sub{ print FIND(sprintf q{:%s\b}, $_[0]); }
  , find => sub{ print FIND(@_) }
  , edit => sub{ exec $ENV{VISUAL} || $ENV{EDITOR}, $ENV{TDONE_FILE}; }
  , next => sub{ my ($next) = LIST; print $next; }
  , help => sub{ qx{perldoc $0}   } # USAGE
};


my $action  = @ARGV == 0           ? $actions->{list}->()
            : $actions->{$ARGV[0]} ? do{ my $verb = shift @ARGV;
                                         $actions->{$verb}->(@ARGV)
                                       }
            :                        $actions->{add}->(@ARGV)
            ;


# float more +'s up to the top as a marker for priority
sub sub_score {my($x,$y)=@_; return 0.5 unless $x && $y; ($x cmp $y) * .4 + .5}
@tasks = sort{ my $a_plus = $a =~ m/^([+]*)/ ? length($1) : 0;
               my $a_loc  = $a =~ m/(\@\w+)/ ? $1 : '';
               my $b_plus = $b =~ m/^([+]*)/ ? length($1) : 0;
               my $b_loc  = $b =~ m/(\@\w+)/ ? $1 : '';
               my $a_score= $a_plus + sub_score($a_loc,$b_loc);
               my $b_score= $b_plus + sub_score($b_loc,$a_loc);
               #warn "  A: $a_plus $a_loc => $a_score\n  B: $b_plus $b_loc => $b_score \n\n";
               $b_score <=> $a_score;
             } @tasks;

# clean up any blank lines
@tasks = grep{length} @tasks; 

# write happens when @tasks goes out of scope

=head1 NAME 

  tdone : because the world really needs yet another 

=head2 USAGE

  tdone.pl [action] [task]

=head2 INSTALLL

=over

=item 1: have a version of perl installed >= 5.10 (unsure use: perl -v)

=item 2: Put tdone.pl some where in your PATH

=item 3: set TDONE_FILE in your enviroment to a file like ~/.tdone_list


=back

=head2 SYNTAX

=over

=item B<priority> is determined by the number of +'s at the start of a task.
For example +++ is more imporant then + and when you view your list it will be
sorted for you with the highest priority first.

=item B<tags> are intended to be preceeded with a colon (:), though is just
used for coloring when displaying the list of tasks. There is a provided verb
(tag) that will only look for words that begin with :.

=item B<locaiton> is marked with an apetail/at sign (@). There is a provided
verb (at) that will only look for words that begin with @.

=back

=head2 VERBS

=over

=item B<list> : show a list of the file with added indexes (B<DEFAULT> action if no input is given)

=item B<add>  : add a new task to the file (B<DEFAULT> action if input is given but no action is given)

=item B<did>  : remove a task from the file, takes any number of id's from list

=item B<find> : search file for a given string (treated as a regular expression)

=item B<at>   : search file for a given location (treated as a regular expression)

=item B<tag> : search file for a given tag (treated as a regular expression)

=item B<edit> : open up the file in what ever your evniroment states as your prefered editor

=back


=head2 EXAMPES

  > tdone.pl list
  > tdone.pl add +++ some very important task @office :project
  > tdone.pl ++ some slightly important task @office :meeting
  > tdone.pl get milk @store :food :grocieres 
  > tdone.pl list
  0: +++ some very important task @office :project
  1: ++ some slightly important task @office :meeting
  2: get milk @store :food :grocieres
  > tdone.pl find important
  0: +++ some very important task @office :project
  1: ++ some slightly important task @office :meeting
  > tdone.pl tag food
  2: get milk @store :food :grocieres
  > tdone.pl at office
  1: ++ some slightly important task @office :meeting
  > tdone.pl did 2 0
  > tdone.pl
  0: ++ some slightly important task @office :meeting

=head2 ADVANCED TIPS

The first thing that did was remove the need for the .pl 

  > ln -s tdone.pl tdone

Then because this is as simple as it get's I am not going to impliment anything
like projects. Though that does not imply that you are stuck putting
everything in to a single massive file (yuk!). Remember that the todo list
file is just an evniroment var thus you can always do this: 

  > TDONE_FILE=~/.tdone/project_foo tdone ++ make this todo list thing simpler
  > TDONE_FILE=~/.tdone/project_foo tdone 
  0: ++ make this todo list thing simpler

But that is ugly and a lot to type so just alias it away: 

  > alias foo='TDONE_FILE=~/.tdone/project_foo tdone'
  > foo did 0
  > foo ++ setup :gh_pages for project :foo @laptop
  > foo
  0: ++ setup :gh_pages for project :foo @laptop

This method also makes building shopping lists simple: 

  > alias get='TDONE_FILE=./shopping tdone'
  > get milk @grocery
  > get plants @nursery
  > get nails @hardware

Then using the at filter becomes your location aware shopping list:

  > get at grocery 
  0: milk @grocery
  > alias got='get did'
  > got 0
  > get
  0: plants @nursery
  1: nails @hardware

Another handy one for bugtracking is : 

  > alias bug='TDONE_FILE=./bugs tdone'
  > cd ~/git/project_foo
  > bug +++ login with empty :password causes user to :delete there account!

Lastly becase these are just simple text files I have them all stored in my
DropBox folder so syncing is doine and I get access via all my devices.

=head2 POSSIBLE CHANGES IN FUTURE VERSIONS

Currently I have provided the verbs B<list> and B<add> to be explict though I
personaly never use them as the code already can infer them. There is also the
possible issue of them being expected for the task in the case of no priority
given:

  tdone.pl add add a :feature to the site @office

Though the same can be said for all of the other verbs. I have been thinking
about how to resolve this issue and so far the only I<clean> way I can think of
is to completely remove all verbs. The B<find> verbs can be done by aliasing with
something like ack or grep, but they will have to be there own words at that
point. In the case of B<edit>, and B<did> it become complex as the TDONE_FILE
is harder to infer for the right action to result.

The alternate in these cases would be to result to using flagged options,
B<-e> for example in the case of B<edit>) as a way to resolve the syntax
issues but I find this a bit ugly but it is reliable. Thus be warned that at
some point there might be an alternate version that changes the syntax. In
either case I will likely save this off as tdone2.pl and leave it to the user
to pick which version they will prefer. 

=head2 GOT FEEDBACK?

Love it? Hate it? Want to see something changed? Feel free to use the issue
tracker to let me know.
