#!/bin/bash

# run this with $ source ppNTuples_condor_submit.sh 
#if arguments use $ source ppNTuples_condor_submit.sh $arg1 $arg2 ... etc.

echo "inputs are \$flavor \$BeginJob \$EndJob \$JobSplittng"
echo "to run one job let BeginJob=EndJob"
job=0
flavor=$1
BeginJob=$2
EndJob=$3
JobSplitting=$4

echo "makeNTuple Jobs Being Submitted..."

ScratchDir="/net/hidsk0001/d00/scratch/ilaflott/pp_NTuples"
NTupleDir=""
NTupleFileName=""
FinalNTupleFileName=""

if [ $flavor -eq 0 ]; then
    echo "Data Job Being Submitted"
#    NTupleDir="${ScratchDir}/Data_redo_11.1"
    NTupleDir="${ScratchDir}/Data_MaybeBadAndOldFiles_11.1"
    NTupleFileName="${NTupleDir}/data_NTuple_11.1_"
fi
if [ $flavor -eq 1 ]; then
    echo "QCDJet Job Submitted"
    NTupleDir="${ScratchDir}/QCDJets_Official_noVsJets"
    NTupleFileName="${NTupleDir}/QCDJets_NTuple_noVsJets_11.1_"
fi
if [ $flavor -eq 2 ]; then
    echo "BJet Job Being Submitted"
#    NTupleDir="${ScratchDir}/BJets_OfficialLowPtAndPrivateGenHighPT_11.1"
    NTupleDir="${ScratchDir}/BJets_addStat_11.1"
    NTupleFileName="${NTupleDir}/BJets_NTuple_addStat_11.1_"
fi
if [ $flavor -eq 3 ]; then
    echo "CJet Job Being Submitted"
#    NTupleDir="${ScratchDir}/CJets_OfficialLowPtAndPrivateGenHighPT_11.1"
    NTupleDir="${ScratchDir}/CJets_addStat_11.1"
    NTupleFileName="${NTupleDir}/CJets_NTuple_addStat_11.1_"
fi

JobNum=$BeginJob
#echo '${JobNum}'
#EndJob=5 #debug

while [ $JobNum -le $EndJob ]
do  

    FinalNTupleFileName="${NTupleFileName}_${JobNum}_of_${JobSplitting}.root"
    if [ ! -e $FinalNTupleFileName ]; then
        echo "file ${FinalNTupleFileName} does not exist!"
    else 
	#echo "file exists"
        actualsize=$(wc -c <"${FinalNTupleFileName}")
       
        if [ $actualsize -le 8500 ]; then
	    echo "actualsize=${actualsize}"
            echo "file ${FinalNTupleFileName} does exist but isn't big enough!"
	else
#            echo "file ${FinalNTupleFileName} exists and is big enough! DON'T SUBMIT"
            JobNum=$(($JobNum + 1))
            continue
        fi
    fi
    echo "running job..."
    nice -n 19 root -b -l -q "bTagNTuple.C+(${job},${flavor},${JobNum},${JobSplitting})" >& "local_logs/makeNTuple_Flav_${flavor}_p${JobNum}_of_${JobSplitting}.log"
    #root -b -l -q "bTagNTuple.C+(${job},${flavor},${JobNum},${JobSplitting})" >& "local_logs/makeNTuple_Flav_${flavor}_p${JobNum}_of_${JobSplitting}.log"

#    sleep 1s

    echo "moving file"
    ls *"_${JobNum}_of_${JobSplitting}.root"
    mv *"_${JobNum}_of_${JobSplitting}.root" "${NTupleDir}"

#    sleep 1s
    
    JobNum=$(($JobNum + 1))
    
done