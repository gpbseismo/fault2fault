: # use perl
eval 'exec $ANTELOPE/bin/perl -S $0 "$@"'
if 0;

use lib "$ENV{ANTELOPE}/data/perl" ;
use Datascope ;
require "getopts.pl" ;

if ( !&Getopts('vV') || $#ARGV<0) {
   die "$0 [-vV] sectionlist\n" ;
} else {
   $infile = $ARGV[0] ;
}
die "infile missing\n"  unless open(IN, "$infile") ;
$isect = 0;
@sect = [] ;
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
   print "SectionIndex = $line\n" if $opt_v;
   $k++; $line = $all[$k]; chomp($line) ;
   $SectionName = $line ;
   $k++; $line = $all[$k]; chomp($line) ;
   $ParentSectionID = $line ;
   $k++; $line = $all[$k]; chomp($line) ;
   $ParentSectionName = $line ;
   print "ParentSectionName = $line\n" if $opt_v;
   $k++; $line = $all[$k]; chomp($line) ;
   $AveUpperSeisDepth = $line ;
   $k++; $line = $all[$k]; chomp($line) ;
   $AveLowerSeisDepth = $line ;
   $k++; $line = $all[$k]; chomp($line) ;
   $Dip = $line ;
   print "Dip = $line\n" if $opt_v;
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
   print "$k  TraceLength = $line\n" if $opt_v;
   $k++; $line = $all[$k]; chomp($line) ;
   $NumTracePoints = $line ;
   print "NumTracePoints = $line\n" if $opt_v;
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
      print "kkey: $key $sect[$isect]{$key}\n";
   }
   if ( $opt_V) { 
      print "pausing \n" ;
      $toss = <STDIN> ;
   }
   
   $isect++;
}
print "Sect hash length: $#sect \n";
print "second Lon $sect[$isect-1]{'Lon'}[1] \n" if $opt_V;
print "second Lon $sect[1]{'Lon'}[1] \n" ;  # 
print "second Lon $sect[2]{'Lon'}[1] \n" ;  # 

print " sect name  $sect[1]{'SectionName'} \n" ;  # equivalent to below
print " sect name  $sect[2]{'SectionName'} \n" ;  # equivalent to below
print " sect name  ${$sect[1]}{'SectionName'} \n" ;  # 
print " sect name  ${$sect[2]}{'SectionName'} \n" ;  # 


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
