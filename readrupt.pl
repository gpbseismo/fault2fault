: # use perl
eval 'exec $ANTELOPE/bin/perl -S $0 "$@"'
if 0;

use lib "$ENV{ANTELOPE}/data/perl" ;
require 'getopts.pl' ;

if (!&Getopts('v') || $#ARGV<0) {

   die "$0 [-v] rupture_section_file\n";
} else {
   die "trouble opening $ARGV[0]\n" unless open(IN, "$ARGV[0]") ;
}

$irupt = -1 ;
foreach $line (<IN>) {
   next unless ($line=~/^\d/) ;
   $irupt++;
   @x = split(/\s+/, $line) ;
   $rupt[$irupt] = shift(@x) ;
   $clusterID[$irupt] = shift @x ;
   $ruptInClustID[$irupt] = shift @x ;
   $sectionList[$irupt] = [ @x ] ;
   print "$rupt[$irupt] cid: $clusterID[$irupt] ric: $ruptInClustID[$irupt] first section: $sectionList[$irupt][0]\n"  if $opt_v ;
   $nsect = @{$sectionList[$irupt]}  ;
   print "nsect $nsect\n";
}



__END__
rupID	clusterID	rupInClustID	sect1_ID	sect2_ID	...
0	0	0	0	1
1	0	1	0	1	2
20610	24	149	703	704	705	706
20611	24	150	704	705
20612	24	151	704	705	706
20613	24	152	705	706
