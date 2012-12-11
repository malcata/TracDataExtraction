#!/bin/bash

################################################################################
# About                                                                        #
# script to generate priority list for ticket solving	                       #
#                                                                              # 
# v1 by malcata 19-Apr-2011						       #
# v1.1 by malcata 10-Dec-2012, support for arguments                           #
################################################################################

# Check for missing arguments
if [ ! $# == 1 ]; then
   echo "Wrong number of arguments."
   echo "Usage: `basename $0` <PROJECT_NAME>"
   echo "e.g.: $0 projectX"
   exit 1;
fi

project=$1

# working folder
#cd ~/scripts

#CSV header
#echo "project,id,status,type,summary,created,modified,component,priority,severity,owner" > temp/defects.csv
#echo "project,id,status,type,summary,created,modified,component,priority,severity,owner" > temp/bugs.csv

printf "Hi,\nIn attach follows the top ticket list ordered by Severity and then Priority and ID, defects always come first.\nPlease fix tickets ordered this way.\n\n" > temp/mailbody.txt

# get tickets of type Bug or Defect not Closed yet already sorted
grep ",defect," temp/$project.TracData.yesterday.csv | grep -v ",closed," >> temp/defects.csv
grep ",bug," temp/$project.TracData.yesterday.csv | grep -v ",closed," >> temp/bugs.csv

# sort by Severity (in each Defect & Bug)
grep ",S1- Critical," temp/defects.csv > temp/tickets_sort.csv;
grep ",S1- Critical," temp/bugs.csv >> temp/tickets_sort.csv;
grep ",S2- Major," temp/defects.csv >> temp/tickets_sort.csv;
grep ",S2- Major," temp/bugs.csv >> temp/tickets_sort.csv;
grep ",S3- Minor," temp/defects.csv >> temp/tickets_sort.csv;
grep ",S3- Minor," temp/bugs.csv >> temp/tickets_sort.csv;
grep ",S4- Trivial," temp/defects.csv >> temp/tickets_sort.csv;
grep ",S4- Trivial," temp/bugs.csv >> temp/tickets_sort.csv;

# add top priority 10 tickets to mailbody
head -15 temp/tickets_sort.csv | cut -f 1-5,10 >> temp/mailbody.txt
printf "...\n" >> temp/mailbody.txt

# generate some estatistical data
printf "\nDefects open by severity (#%d):\n" `wc -l temp/defects.csv | sed 's/^ *\(.*\) *$/\1/' | cut -d " " -f 1` >> temp/mailbody.txt 
cut -d "," -f 10 temp/defects.csv | sort | uniq -c >> temp/mailbody.txt

printf "\n\nBugs open by severity (#%d):\n" `wc -l temp/bugs.csv | sed 's/^ *\(.*\) *$/\1/' | cut -d " " -f 1` >> temp/mailbody.txt 
cut -d "," -f 10 temp/bugs.csv | sort | uniq -c >> temp/mailbody.txt

printf "\n\nTrac Admin\n" >> temp/mailbody.txt

# send e-mail with the CSV in attach
./sendmail.pl -file templates/tickets.config.ini

# remove temporary files
rm -f temp/defects.csv temp/bugs.csv temp/tickets_sort.csv temp/mailbody.txt
