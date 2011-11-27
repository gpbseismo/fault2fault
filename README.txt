Fault-to-fault:

A.  simple 0.5 penalty for d>=1 km
B.  Penalty proportional to distance
C.  Penalty proportional to distance, but every addition also is penalized, say, relative to parallel SS
D.  Penalty ratio, depending on the delta-CCF

Files:

TomrupSet.xml  Rupture set for northern California, used by Tom to develop the 
   version 0 Coulomb association method.


fltdistances   Section separation distances for all California sections in ruptures.
   1452 of 5196 are zero separation w/in machine noise (1e-12).
   The norcal version is in file "tomruptfaultdistances".
   Read this with readdistances.pl
   Example:
   "name1",id1,"name2",id2,minDist,maxDist
   "0. Anacapa-Dume, alt 1, Subsection 0",0,"1. Anacapa-Dume, alt 1, Subsection 1",1,0.0,30.796462551412045  (zero separation)
   "1. Anacapa-Dume, alt 1, Subsection 1",1,"2. Anacapa-Dume, alt 1, Subsection 2",2,0.0,31.034681093939323
   "2. Anacapa-Dume, alt 1, Subsection 2",2,"3. Anacapa-Dume, alt 1, Subsection 3",3,0.0,32.10200071222228
   ...
   "97. Casmalia (Orcutt Frontal), Subsection 0",97,"525. Hosgri, Subsection 2",525,9.972468448606302,20.123564130547074
   "1439. Santa Ynez (East), Subsection 5",1439,"1531. Ventura-Pitas Point, Subsection 0",1531,9.98135794511377,25.26379564415008
   "430. Great Valley 9, Subsection 3",430,"899. Ortigalita, Subsection 11",899,9.981363359643723,24.613381072851368
   "813. Monte Vista-Shannon, Subsection 4",813,"1250. San Andreas (Peninsula), Subsection 6",1250,9.987666271258492,22.25384848864537
   "534. Hosgri, Subsection 11",534,"1403. San Luis Range (So Margin), Subsection 9",1403,9.994480386704915,26.47743969355024  9.99 km separation

id.txt  Use unknown
id2.txt  Use unknown

inputsections.pl  Reads sectionsForTom section dbase.  (see example below)
   Each section is characterized by 15 lines of parameters.  
   Script reads the section data and builds a structure with section information in it.  
   Likely use:  Setup/input for other analyses

readdistances.pl
   Script to read file fltdistances and tomruptfaultdistances
   Key component: section pairs by number plus their min and max separations.
   Hash dist includes section numbers, min dist, max dist, and section names.
   Should revise to two hashes with keys sect1_sect2 and value of the min and max distance.
   Concept:  facilitate tests of logic in other programs, if (key exists), use 
      section pair distance separation.

rupturesForTom  Table of rupture id numbers and associated section numbers
   Section numbers are those of file "sectionsForTom"
   Example:
   rupID	clusterID	rupInClustID	sect1_ID	sect2_ID	...
   0	0	0	0	1
   1	0	1	0	1	2
   2	0	2	0	1	2	3
   ...

sectionsForTom   Formatted table of sections, with name, cluster association
   section geometry, rate, slip vector  
   Example, after header lines:
   716
   Zayante-Vergeles, Subsection 9
   53
   Zayante-Vergeles
   0.0
   12.0
   90.0
   36.16431
   0.1
   0.0
   150.0
   5.79119
   2
   37.05581	-121.922806
   37.08872	-121.9734


tomruptfaultdistances  Separations for sections closer than 10 km in the northern
   California rupture set TomrupSet.xml.
   663 of these are zero distance separation, within rounding

top2  Scratch file
topsections  Scratch file
