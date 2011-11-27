: # use perl
eval 'exec $ANTELOPE/bin/perl -S $0 "$@"'
if 0;

use lib "$ENV{ANTELOPE}/data/perl" ;
use Datascope ;
require "getopts.pl" ;

if (!&Getopts('vV') || $#ARGV<0) {
   die "$0 [-v] separation_table\n" ;
} else {
   $infile = $ARGV[0] ;
   die "cant find input file\n" unless open(IN, "$infile") ;
}

@dist = [] ;
$k = -1 ;
while (<IN>) {

   ~m/\"(.*)\",(\d+),\"(.*)\",(\d+),(\d.*),(\d.*)/ ;
   $name1 = $1 ;
# print "name1 $name1  " if $opt_V ;
   $id1   = $2 ;
   $name2 = $3 ;
   $id2   = $4 ;
   $mindist = $5 ;
   $maxdist = $6 ;
   # %disthash = {} ;
   if ($k>=0) {
       $dist[$k] = {"name1", $name1,
                 "id1", $id1,
                 "name2",  $name2,
                 "id2",  $id2,
                 "mindist",  $mindist,
                 "maxdist",  $maxdist};
       
      # prints a hash reference  print "k: $k dist sub k: $dist[$k]\n" if $opt_V ;
      $ikey = 1;
       foreach $key ( keys %{$dist[$k]}  ) {
          print "ikey: $ikey key: $key value: $dist[$k]{$key}\n" if $opt_V ;
          $ikey++ ;
       }

   }
   $k++ ;    

}    # end while

$nelements = 1 + $#dist ;
print "dist has $nelements elements\n" if $opt_v;
if ($opt_V) {
   for ($kk=0; $kk<=$#dist; $kk++) {
      print "$kk  name1: $dist[$kk]{'name1'} maxdist: $dist[$kk]{'maxdist'}\n";
   }
}

__END__
"name1",id1,"name2",id2,minDist,maxDist
"640. San Gregorio (So), Subsection 4",640,"641. San Gregorio (So), Subsection 5",641,1.41464777669853E-12,16.243970327987636
"697. White Mountains, Subsection 8",697,"698. White Mountains, Subsection 9",698,1.41464777669853E-12,17.890307432684537
"182. Greenville (No), Subsection 3",182,"183. Greenville (So), Subsection 0",183,2.121971665047795E-12,19.479072487418094
"101. Great Valley 1, Subsection 8",101,"119. Great Valley 2, Subsection 0",119,0.011251944266263617,13.37484229957733
"106. Great Valley 10, Subsection 4",106,"107. Great Valley 11, Subsection 0",107,0.13452156714986713,13.84555750767737
