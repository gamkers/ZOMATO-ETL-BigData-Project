#!/bin/bash

# Author:Akash M, Chaitanya S. Chichmalkar, Ayushi Trivedi, Rutul Deshmukh, Srivatsav Mallavarapu 

# Created date:07/05/2023 
# Modified date: 09/05/2023


# Prerequisites:

# 1) Hadoop services are running
# 2) Your home folder is there on HDFS, Hive ware house is set on hdfs to /user/hive/warehouse
# 3) Hive metastore and Hiveserver2 services are running
# 4) A setLocalPath.sh runs successfully
# 5) A setupEnv.sh runs successfully
# 6) Module 1 run successfully


# Description : This script is abstractig module 2 functionality of the project zomato_etl
#               It is invoked from wrapper.sh


# Reference - Project SRS doc
# Usage: ./module_2.sh 

source /home/talentum/zomato_etl/scripts/zomato.properties

log_job_status() {
  log_file=$log_file
  job_step=$1
  spark_submit_command=$2
  job_start_time=$3
  job_end_time=$4
  job_status=$5
  echo $job_id,$job_step,$spark_submit_command,$job_start_time,$job_end_time,$job_status >> "$log_file"
  # Load log file into Hive table
  if [ "$job_status" == "FAILED" ]
  then
    message=$(cat "$log_file")
    echo "Status :$job_status" | ssmtp -s "$job_step"  akhedkar@talentumglobal.com
    bash $localpath/scripts/message.sh "$message" > /dev/null 2>&1 
  fi
}

# Function to log failure
log_failure(){
  job_step="module_2"
  job_status="FAILED"
  # Call log_job_status function with failure parameters
  log_job_status "$job_step" "NA" "$job_start_time" "$job_end_time" "$job_status"
}

job_start_time=$(date '+%Y-%m-%d_%H:%M:%S')
echo "${0} - module2.sh STARTED"

# 1) Functionality - Checking running instance of the application
if [ -z "$(ls -A $localpath/temp)" ];
then
    echo "${0} - Application module 2 instance running in progress"
    touch $localpath/temp/_INPROGRESS
    echo "${0} - Job Start Time is $job_start_time"
    # 2) Functionality - Ceating an hive external table default.dim_country with location to /user/talentum/zomato_etl/zomato_ext/dim_country 
    beeline -u jdbc:hive2://localhost:10000/$HIVE_DB -n $HIVE_USER -p $HIVE_PASS --hivevar dbname=$HIVE_DB -f $localpath/hive/ddl/createCountry.hive > /dev/null 2>&1
    if [ $? -eq 0 ];
    then
        echo "${0} - Hive dim_country table created"
        # 3) Functionality - 
        #1) Ceating an hive temporary/managed table default.raw_zomato without location clause
        #2) Ceating an hive external partition table default.zomato with location to /user/talentum/zomato_etl/zomato_ext/zomato
        beeline -u jdbc:hive2://localhost:10000/$HIVE_DB -n $HIVE_USER -p $HIVE_PASS --hivevar dbname=$HIVE_DB -f $localpath/hive/ddl/createZomato.hive > /dev/null 2>&1
        if [ $? -eq 0 ];
        then
            echo "${0} - Hive raw_zomato and zomato tables created"
            # 4) Functionality - Loading the data into Hive table default.dim_country table from staging area (/home/talentum/proj_zomato/zomato_raw_files)
            beeline -u jdbc:hive2://localhost:10000/$HIVE_DB -n $HIVE_USER -p $HIVE_PASS --hivevar dbname=$HIVE_DB -f $localpath/hive/dml/loadIntoCountry.hive > /dev/null 2>&1
            if [ $? -eq 0 ];
            then
                echo "${0} - Hive dim_country table populated"
                # 5) Functionality - Loading the data from localPrjCsvPath into Hive table default.raw_zomato 
                beeline -u jdbc:hive2://localhost:10000/$HIVE_DB -n $HIVE_USER -p $HIVE_PASS --hivevar dbname=$HIVE_DB -f $localpath/hive/dml/loadIntoRaw.hive > /dev/null 2>&1
                if [ $? -eq 0 ];
                then
                    echo "${0} - Hive raw_zomato table populated"
                    # 6) Functionality - Inserting records into partition table default.zomato by selecting records from default.raw_zomato 
                    beeline -u jdbc:hive2://localhost:10000/$HIVE_DB -n $HIVE_USER -p $HIVE_PASS --hivevar dbname=$HIVE_DB -f $localpath/hive/dml/loadZomato.hive > /dev/null 2>&1
                    if [ $? -eq 0 ];
                    then
                        echo "${0} - Hive zomato table populated"
                        job_step="module_2"
                        spark_submit_command="NA"
                        job_status="SUCCESS"
                        loc_job_end_time=$(date '+%Y-%m-%d_%H:%M:%S')
                        log_job_status "$job_step" "$spark_submit_command" "$job_start_time" "$loc_job_end_time" "$job_status"
                    else
                        log_failure
                        echo "${0} - Failed to load data into zomato table "
                    fi
                else 
                    log_failure
                    echo "${0} - Failed to load data into raw_zomato table " 
                fi
            else
                log_failure
                echo "${0} - Failed to load data into dim_country table "
            
            fi
        else
            log_failure
            echo "Hive raw_zomato and zomato tables creation Failed"       
        fi
    else
        log_failure
        echo "dim_country table creation Failed"
    fi
else
    echo "Another Process Is Running"
    log_failure
fi

rm /home/talentum/zomato_etl/temp/*
echo "${0} - Removal of the instance of module 2 done"

beeline -u jdbc:hive2://localhost:10000/$HIVE_DB -n $HIVE_USER -p $HIVE_PASS --hivevar dbname=$HIVE_DB -f $localpath/hive/ddl/createLogTable.hive > /dev/null 2>&1 
beeline -u jdbc:hive2://localhost:10000/$HIVE_DB -n $HIVE_USER -p $HIVE_PASS --hivevar log=$log_file -f $localpath/hive/dml/loadZomatoSummaryLog.hive > /dev/null 2>&1 
echo "${0} - module_2.sh ENDED"









