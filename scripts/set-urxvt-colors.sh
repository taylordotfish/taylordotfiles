#!/bin/sh
set -euf
printf '\033]4'
printf ';0;[75]#000000'
printf ';8;[75]#4d4d4d'
printf ';232;[75]#080808'
printf ';233;[75]#121212'
printf ';234;[75]#1c1c1c'
printf ';235;[75]#262626'
printf ';236;[75]#303030'
printf ';237;[75]#3a3a3a'
printf ';238;[75]#444444'
printf ';239;[75]#4e4e4e'
printf ';240;[75]#585858'
printf ';241;[75]#626262'
printf ';242;[75]#6c6c6c'
printf ';243;[80]#767676'
printf ';244;[85]#808080'
printf ';245;[90]#8a8a8a'
printf ';246;[95]#949494'
printf '\234'
exec "$@"
