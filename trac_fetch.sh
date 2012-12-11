#!/bin/bash
################################################################################
# About                                                                        #
# script to track TRAC changes					               #
#                                                                              #
# v1 by malcata 15-Apr-2011                                                    #
# v1.1 by malcata 10-Dec-2012, support for arguments                           #
################################################################################


# Check for missing arguments
if [ ! $# == 5 ]; then
   echo "Wrong number of arguments."
   echo "Usage: `basename $0` <TRAC_HOST> <PROJECT_NAME> <TRAC_AUTH> <REPORT_ID> <SEND_EMAIL_FLAG>"
   echo "e.g.: $0 trac.local projectX 67fe78b6d5726d732bc4f1b7d73c8888 15 true"
   exit 1;
fi

project=$2
send_email=$5

# extract project report
curl -k --proxy "" -b trac_auth=$3 https://$1/projects/$project/report/$4?format=csv -o "$project.TracData.today.csv" || exit 1

# clean report - convert dates etc 
cat $project.TracData.today.csv | sed -e 's/T\([0-9][0-9]\):\([0-9][0-9]\):\([0-9][0-9]\)Z,/,/g' |  sed -e 's/T\([0-9][0-9]\):\([0-9][0-9]\):\([0-9][0-9]\)\+\([0-9][0-9][0-9][0-9]\),/,/g' |  sed -e 's/T\([0-9][0-9]\):\([0-9][0-9]\):\([0-9][0-9]\)\+\([0-9][0-9]\):\([0-9][0-9]\),/,/g' > $project.TracData.today.clean.csv
mv $project.TracData.today.clean.csv $project.TracData.today.csv

# load header
echo "project,id,status,type,summary,created,modified,component,priority,severity,owner" > temp/diff.csv

# search for differences
# diff exclude control lines, factories and projects removed for ageing, exclude temps
diff -a -w -U 0 temp/$project.TracData.yesterday.csv $project.TracData.today.csv | grep -v "@@" | egrep -v "\-\-\-" | egrep -v "\+\+\+" >> temp/diff.csv

# prepare mail content
printf "New state entries (sum):\n" > temp/mailbody.txt
egrep -v "^\-.+" temp/diff.csv | cut -d "," -f 3 | grep -v status | sort | uniq -c >> temp/mailbody.txt
printf "\n\nSome details:\n" >> temp/mailbody.txt
cat temp/diff.csv | cut -d "," -f 1-5,10 >> temp/mailbody.txt

# send e-mail with progress using mail template
if [ $send_email == "true" ]; then
   ./sendmail.pl -file templates/diff.config.ini
fi

# backup & compress files
# make available some data for other scripts
mv temp/$project.TracData.yesterday.csv $project.TracData_`date +%F`.csv
gzip --best -f $project.TracData_`date +%F`.csv
mv $project.TracData.today.csv temp/$project.TracData.yesterday.csv
mv $project.TracData_`date +%F`.csv.gz backup/
cp -rf temp/$project.TracData.yesterday.csv backup/

# clean files
rm -f temp/diff.csv
