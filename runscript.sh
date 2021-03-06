#!/bin/csh

set script_start  = `date`

# source /cvmfs/cms.cern.ch/cmsset_default.csh

echo "XXXXXXXXXXXX"
#cat $PWD/.job.ad
echo "XXXXXXXXXXXX"
echo "Submitted by mungaro, rgaDIS"

uname -a

echo " ==== PWD"
pwd

echo " ==== ./"
ls -lhrt ./

echo " ==== /etc/profile.d/"
ls -lhrt /etc/profile.d/

echo " ==== ENV"
env

source /etc/profile.d/environmentB.csh
cd /tmp

#set ClusterId = `sed -n '0,/ClusterId = "\([^"]*\)"/\1/p' $PWD/.job.ad`

set ClusterId = ` awk -F '=' '/^ClusterId/ {print $2}' $PWD/.job.ad`
echo ClusterId $ClusterId


set ProcId = ` awk -F '=' '/^ProcId/ {print $2}' $PWD/.job.ad`
echo ProcId $ProcId


printf "Start time: "; /bin/date
printf "Job is running on node: "; /bin/hostname
printf "Job running as user: "; /usr/bin/id
printf "Job is running in directory: "; /bin/pwd

echo
echo JLAB_ROOT: $JLAB_ROOT
echo

echo starting files
ls -l
set generator_start  = `date`
clasdis --trig 100 --docker --t 15 20
#dvcsgen --trig 71 --docker

echo after generator
echo test finish
ls -l
set gemc_start = `date`
gemc -USE_GUI=0 -N=100 -INPUT_GEN_FILE="lund, sidis.dat"LUMIOPTION_scard /jlab/work/clas12.gcard

echo after gemc
ls -l


set evio2hipo_start = `date`
evio2hipo -r 11 -t -100 -s -100 -i out.ev -o gemc.hipo

echo after decoder
ls -l

set notsouseful_start = `date`
notsouseful-util -i gemc.hipo -o out_gemc.hipo -c 2

echo after cooking
ls -l


echo Moving file
echo $ClusterId
mv out.ev out.$ProcId.ev
mv gemc.hipo gemc.$ProcId.hipo
mv sidis.dat sidis.dat.$ProcId
echo File moved
echo `basename sidis.dat.$ProcId`
echo `basename out.$ProcId.ev`
echo `basename gemc.$ProcId.hipo`
echo `basename out_gemc.$ProcId.hipo`


echo creating directory
mkdir out_`basename $ClusterId`_n100
echo moving file
mv sidis.dat.$ProcId out_`basename $ClusterId`_n100
mv out.$ProcId.ev out_`basename $ClusterId`_n100
mv gemc.$ProcId.hipo out_`basename $ClusterId`_n100
mv out_gemc.hipo out_gemc.$ProcId.hipo
mv out_gemc.$ProcId.hipo out_`basename $ClusterId`_n100

echo copying gcard and scard
cp /jlab/work/clas12.gcard out_`basename $ClusterId`_n100
cp scard_name out_`basename $ClusterId`_n100

#final job log
printf "Job finished time: "; /bin/date

echo "script started at" $script_start
echo "generator started at" $generator_start
echo "gemc started at" $gemc_start
echo "evio2hipo started at" $evio2hipo_start
echo "notsouseful started at" $notsouseful_start
