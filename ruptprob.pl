: # use perl
eval 'exec $ANTELOPE/bin/perl -S $0 "$@"'
if 0;

use lib "$ENV{ANTELOPE}/data/perl" ;
require "getopts.pl" ;

if (!&Getopts('v') || $#ARGV<0 ) {
   die "$0 [-v] outfile\n" ;
} else {
   $outfile = $ARGV[0] ;
}

# files and parameters
   $sectionFile = "sectionsForTom" ;   # expect last index 716
   $sectDistFile = "tomruptfaultdistances" ;  # expect 1980; last index 1979
   $ruptSectListFile = "rupturesForTom" ;   # expect last index 20613
   $steppenaltydistance = 1.0 ;
   $steppenalty         = 0.5 ;
   $r0                  = 1.5 ;

@sect = &inputsections_sub( $sectionFile ) ;
print "read in $#sect plus one section descriptions\n" if $opt_v ;
@dist = &readdistances_sub( $sectDistFile ) ;
print "separations for $#dist pairs of sections read\n" if $opt_v ;
@sectionList = &readrupt_sub( $ruptSectListFile ) ;
# array of arrays: index of sectionList is the rupture id, the array it list of sections in the rupture
print "number of input ruptures: $#sectionList elements\n" if $opt_v ;

# extract from dist all pairs of sections, and their compliments.
# form will be 14_323 and compliment 323_14
# These will both be hash keys to minimum distance (for now)
# hash will be called disthash

%disthash = &makedisthash( @dist ) ;
@dkeys = keys %disthash ;
print "number of keys in disthash:  $#dkeys\n" if $opt_v ;

# then go through the rupture list
# for each rupture,
#    for each consecutive pair of sections
#       find distance separation from disthash, or complain
#       apply penalty (P = 0.49P) if dist >=1.0 km
#       alt, apply penalty as function of distance r
#    return P for each rupture

@x    = &makePrupt( \%disthash, $steppenaltydistance, $steppenalty, $r0, @sectionList ) ;
@P1 = @{ $x[0] } ;
@P2 = @{ $x[1] } ;
$minP1 = &getminP(@P1) ;
$minP2 = &getminP(@P2) ;
print "minP1: $minP1 minP2: $minP2\n";


## sub ##############################################

sub inputsections_sub {
   local($infile) = shift(@_) ;
   die "file $infile missing\n"  unless open(IN, "$infile") ;

$isect = 0;
local(@sect) = [] ;
@all = <IN> ;
$k = -1 ;
while ($k< $#all) {
   $k++;
   $line = $all[$k] ;
#  if ( 0 ) {
   chomp($line);
   $line =~s/^\s+// ;
   while ($line=~/^#/) {
      $k++ ;
      $line = $all[$k] ;
      chomp($line);
      $line =~s/^\s+// ;
   }
# } # end if 0
   
   $SectionIndex = $line ;
   print "SectionIndex = $line\n" if $opt_V;
   $k++; $line = $all[$k]; chomp($line) ;
   $SectionName = $line ;
   $k++; $line = $all[$k]; chomp($line) ;
   $ParentSectionID = $line ;
   $k++; $line = $all[$k]; chomp($line) ;
   $ParentSectionName = $line ;
   print "ParentSectionName = $line\n" if $opt_V;
   $k++; $line = $all[$k]; chomp($line) ;
   $AveUpperSeisDepth = $line ;
   $k++; $line = $all[$k]; chomp($line) ;
   $AveLowerSeisDepth = $line ;
   $k++; $line = $all[$k]; chomp($line) ;
   $Dip = $line ;
   print "Dip = $line\n" if $opt_V;
   $k++; $line = $all[$k]; chomp($line) ;
   $DipDirection = $line ;
   $k++; $line = $all[$k]; chomp($line) ;
   $AveLongTermSlipRate = $line ;
   $k++; $line = $all[$k]; chomp($line) ;
   $AveAseismicSlipFactor = $line ;
   $k++; $line = $all[$k]; chomp($line) ;
   $AveRake = $line ;
   $k++; $line = $all[$k]; chomp($line) ;
   $TraceLength = $line ;
   print "$k  TraceLength = $line\n" if $opt_V;
   $k++; $line = $all[$k]; chomp($line) ;
   $NumTracePoints = $line ;
   print "NumTracePoints = $line\n" if $opt_V;
   @lat = [];  @lon=[];
   for ($j = 0; $j<$NumTracePoints   ; $j++) {
      $k++; $line = $all[$k]; chomp($line) ;
      @x = split(/\s+/, $line) ; 
      $lat[$j] = $x[0] ;
      $lon[$j] = $x[1] ;
   }
   $sect[$isect] = { "SectionIndex", $SectionIndex,
      "SectionName", $SectionName,
      "ParentSectionId", $ParentSectionID,
      "ParentSectionName", $ParentSectionName,
      "AveUpperSeisDepth", $AveUpperSeisDepth,
      "AveLowerSeisDepth", $AveLowerSeisDepth,
      "Dip", $Dip,
      "DipDirection", $DipDirection,
      "AveLongTermSlipRate", $AveLongTermSlipRate,
      "AveAseismicSlipFactor", $AveAseismicSlipFactor,
      "AveRake", $AveRake,
      "TraceLength", $TraceLength,
      "NumTracePoints", $NumTracePoints,
      "Lat", [@lat],   # could be okay
      "Lon", [@lon]} ;
   
   foreach $key ( keys %{$sect[$isect]}  ) {
      print "kkey: $key $sect[$isect]{$key}\n" if $opt_V;
   }
   if ( $opt_V) { 
      print "pausing \n" ;
      $toss = <STDIN> ;
   }
   
   $isect++;
}
close(IN) ;
return @sect ;

# print "Sect hash length: $#sect \n";
# print "second Lon $sect[$isect-1]{'Lon'}[1] \n" if $opt_V;
# print "second Lon $sect[1]{'Lon'}[1] \n" ;  # 
# print "second Lon $sect[2]{'Lon'}[1] \n" ;  # 

# print " sect name  $sect[1]{'SectionName'} \n" ;  # equivalent to below
# print " sect name  $sect[2]{'SectionName'} \n" ;  # equivalent to below
# print " sect name  ${$sect[1]}{'SectionName'} \n" ;  # 
# print " sect name  ${$sect[2]}{'SectionName'} \n" ;  # 


# Section Index
# Section Name
# Parent Section ID
# Parent Section Name
# Ave Upper Seis Depth (km)
# Ave Lower Seis Depth (km)
# Ave Dip (degrees)
# Ave Dip Direction
# Ave Long Term Slip Rate
# Ave Aseismic Slip Factor
# Ave Rake
# Trace Length (derivative value) (km)
# Num Trace Points
# lat1 lon1
# lat2 lon2
}
## sub ##############################################

sub readdistances_sub {
   local($infile) = shift(@_) ;
   die "cant find input file $infile\n" unless open(IN, "$infile") ;


local(@dist) = [] ;
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
print "dist has $nelements elements\n" if $opt_V;
if ($opt_V) {
   for ($kk=0; $kk<=$#dist; $kk++) {
      print "$kk  name1: $dist[$kk]{'name1'} maxdist: $dist[$kk]{'maxdist'}\n";
   }
}
return @dist ;
}   # end sub

## sub ##############################################

sub readrupt_sub {
   local ($ruptfile) = shift(@_) ;
   # example infile:  rupturesForTom
   die "trouble opening $ruptfile\n" unless open(IN, "$ruptfile") ;
   local( @sectionList ) ;

$irupt = -1 ;
foreach $line (<IN>) {
   next unless ($line=~/^\d/) ;
   $irupt++;
   @x = split(/\s+/, $line) ;
   $ruptid = shift(@x) ;
   $rupt[$ruptid] = $irupt ;
   $clusterID[$ruptid] = shift @x ;
   $ruptInClustID[$ruptid] = shift @x ;
   $sectionList[$ruptid] = [ @x ] ;
   # print "$rupt[$irupt] cid: $clusterID[$irupt] ric: $ruptInClustID[$irupt] first section: $sectionList[$irupt][0]\n"  if $opt_v ;
   $nsect = @{$sectionList[$ruptid]}  ;
   # print "nsect $nsect\n";
}
return @sectionList ;
}

## sub ##############################################
sub makedisthash {

   local( @dist ) = @_ ;
   local( %disthash ) ;
   local( $id1, $id2, $mindist, $maxdist, %tmp ) ;
   $npairs = $#dist ;
   
   for ($pair = 0; $pair<$npairs; $pair++) {
      %tmp = %{ $dist[$pair] } ;
      $id1 = $tmp{'id1'} ;
      $id2 = $tmp{'id2'} ;
      $mindist = $tmp{'mindist'} ;
      $key1 = "${id1}_$id2" ;
      $key2 = "${id2}_$id1" ;
      $disthash{ $key1 } = $mindist ;
      $disthash{ $key2 } = $mindist ;
      print "key1: $key1  key2: $key2 mindist: $mindist\n" if $opt_V;
   }
   return %disthash ; 

} # end sub

## sub ##############################################
sub makePrupt {

   local( $ptrtodisthash )  = shift(@_) ;
   local( $steppenaltydistance ) = shift(@_) ;
   local( $steppenalty         ) = shift(@_) ;
   local( $r0                  ) = shift(@_) ;
   local( @sectionList )  = @_ ;
   # array of arrays: index of sectionList is the rupture id, the array it list of sections in the rupture
   local %disthash ;
   local $nrupt, $nsects, $id1, $id2 ;
   local @P, @P2 ;
   %disthash = %{ $ptrtodisthash } ;
   @dkeys = keys %disthash ;
   print "in makePrupt number of keys in disthash:  $#dkeys  nrupt: $#sectionList\n";

# then go through the rupture list
# for each rupture,
#    for each consecutive pair of sections
#       find distance separation from disthash, or complain
#       apply penalty (P = 0.49P) if dist >=1.0 km
#       alt, apply penalty as function of distance r
#    return P for each rupture
   
   $nrupt = $#sectionList ;
   for ($irupt = 0; $irupt<=$nrupt; $irupt++) {
      $P[$irupt] = 1 ;
      $P2[$irupt] = 1 ;
      @sects = @{ $sectionList[$irupt] } ;
      print "irupt: $irupt nsects: $#sects\n" if $opt_V;
      $nsects = $#sects ;  # 1 fewer than the real number; index space
      for ($ip = 1; $ip<=$nsects; $ip++) {
         $id1 = $sects[$ip-1] ;
         $id2 = $sects[$ip  ] ;
         $key1 = "${id1}_$id2" ;
         $key2 = "${id2}_$id1" ;
         $found = 0 ;
         $mindist1 = -1 ;
         if ( exists $disthash{$key1} ) {
            $mindist1 = $disthash{$key1} ;
         }
         $mindist2 = -1 ;
         if ( exists $disthash{$key2} ) {
            $mindist2 = $disthash{$key2} ;
            if ( ! exists $disthash{$key1} ) {
               $found = 1 ;
            }

         }
         $mindist2 = $disthash{$key2} ;

         # print "irupt: $irupt nsects: $#sects $ip $key1 $key2 md1 $mindist1 md2 $mindist2\n" if $mindist2>0.99;

         # see if there are any cases where key2 is discovered but not key1  (None, maybe by construction)
         if ($found) {
            print "irupt: $irupt nsects: $#sects $ip $key1 $key2 md1 $mindist1 md2 $mindist2\n" ;
         }
         
         # Now apply the geometric penalty, $steppenalty if distance > $steppenaltydistance, typ 0.5 if >1.0 km
         if ( $mindist1>$steppenaltydistance || $mindist2>$steppenaltydistance) {
            $P[$irupt] = $steppenalty * $P[$irupt] ;
         }

         # Now apply an exponential distance penalty

         $P2penalty = exp(-$mindist1/$r0) ;
         $P2[$irupt] = $P2penalty * $P2[$irupt] ;

      }
      print "$irupt  P: $P[$irupt] P2: $P2[$irupt]\n";

   }

   @x = (\@P, \@P2) ;
   return @x ;
}

## sub ##############################################
sub getminP {
   local(@P) = @_ ;
   local $minP = 99;
   for ($k=0; $k<=$#P; $k++) {
      if ($P[$k] < $minP) {
         $minP = $P[$k] ;
      }
   }
   return $minP ;
}
#####################################################
