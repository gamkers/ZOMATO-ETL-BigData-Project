#!/bin/bash

# Author:Akash M, Chaitanya S. Chichmalkar, Ayushi Trivedi, Rutul Deshmukh, Srivatsav Mallavarapu 

# Created date:07/05/2023 

# Modified date: 09/05/2023

# Description: This Module contains cleaning up the hive tables, creating HDFS directories, 
# moving the JSON files from staging area to the source directory, 
# deleting the archive files and creating the temp folder.

# Usage: Setting up the environment

source /home/talentum/zomato_etl/scripts/zomato.properties

echo "${0} - SETUP SCRIPT STARTED"
#1) Functionality Dropping all the project related Hive tables if exists, using a beeline interface
echo "${0} - CLEANING THE HIVE DATABASE STARTED"
beeline -u jdbc:hive2://localhost:10000/$HIVE_DB \
-n $HIVE_USER -p $HIVE_PASS --hivevar dbname=$HIVE_DB \
-f $localpath/hive/ddl/cleanhive.hive > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "${0} - Hive clean script executed successfully"
else
    echo "${0} - Hive clean script failed"
    exit 1
fi

#2) Functionality Setting up HDFS file system paths for zomato etl project
bash $localpath/scripts/hdfsdir.sh  
if [ $? -eq 0 ]; then
    echo "${0} - HDFS directories created successfully"
else
    echo "${0} - HDFS directories creation failed"
    exit 1
fi

#3) Functionality Copy json files from -/proj.zomato/zomato_raw_files/file(1..3).json to /proj_zomato/zomat

if [ "$(ls -A $localpath/source/json)" ]; then
   echo "$localpath/source/json is not empty"
   rm /home/talentum/zomato_etl/source/json/*
   echo "${0} - Existing files deleted from $local/source/json"
else
   echo "${0} - $localpath/source/json is empty"
fi

cp ~/shared/file[123].json /home/talentum/zomato_etl/source/json/
cp ~/shared/*.csv /home/talentum/zomato_etl/source/csv/


echo "${0} - JSON files copied successfully"

#4) Functionality- Deleting files achieved into -/proj_romato/zomato_etl/archieve
echo "${0} - DELETING ARCHIVE FILES FROM $localpath/archive"
rm $localpath/archive/*
echo "${0} - DELETED ARCHIVE FILES FROM $localpath/archive"


#5) Functionality Deleting -/zomato etl/temp folder if exists, which abstracts the running instance of an application. Else create the one

# Check if temp directory exists
if [ -d "$TEMP_DIR" ]; then
    # Temp directory exists, delete it 
    echo "${0} - $localpath/temp exists"   
    echo "${0} - Deleting $localpath/temp directory"
    rm -rf "$TEMP_DIR"
     echo "${0} - $localpath/temp Deleted"
fi

echo "${0} - Creating $localpath/temp"
mkdir -p "$TEMP_DIR"
echo "${0} - $localpath/temp created"
