# NAME 

  tdone : because the world really needs yet another 

## USAGE

  tdone.pl [action] [task]

## INSTALLL

1. Put tdone.pl some where in your PATH

2. Touch a file and then set TDONE_FILE in your enviroment

3. done =)

## VERBS

**list** : show a list of the file with added indexes (**DEFAULT** action if no input is given)

**add**  : add a new task to the file (**DEFAULT** action if input is given but no action is given)

**did**  : remove a task from the file, takes any number of id's from list

**find** : search file for based on a given regular expression

**edit** : open up the file in what ever your evniroment states as your prefered editor

## SYNTAX

**priority** is determined by the number of +'s at the start of a task.

## EXAMPES

    > tdone.pl list
    > tdone.pl add +++ some very important task @office :project
    > tdone.pl ++ some slightly important task @office :meeting
    > tdone.pl get milk @store :food :grocieres 
    > tdone.pl list
    0: +++ some very important task @office :project
    1: ++ some slightly important task @office :meeting
    2: get milk @store :food :grocieres
    > tdone.pl did 2 0
    > tdone.pl
    0: ++ some slightly important task @office :meeting

  
