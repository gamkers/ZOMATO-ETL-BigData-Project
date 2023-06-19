#!/bin/bash

# Author:Akash M, Chaitanya S. Chichmalkar, Ayushi Trivedi, Rutul Deshmukh, Srivatsav Mallavarapu 

# Created date:07/05/2023 
# Modified date: 09/05/2023

# Description: The script is abstracting module 1 functionality of the project 
# Usage: ./module1.sh

source /home/talentum/zomato_etl/scripts/zomato.properties
log=$log_file
job_start_time=$(date '+%Y-%m-%d_%H:%M:%S')
echo "${0} - module1.sh STARTED"
#4) Functionality - Adding log message into a log file on local file system 
log_job_status() {
  log_file=$log_file
  job_step=$1
  spark_submit_command=$2
  job_start_time=$3
  job_end_time=$4
  job_status=$5
  echo $job_id,$job_step,$spark_submit_command,$job_start_time,$job_end_time,$job_status >> "$log"
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
  job_step="module_1"
  job_status="FAILED"
  # Call log_job_status function with failure parameters
  log_job_status "$job_step" "$spark_submit_command/conversion.py" "$job_start_time" "$job_end_time" "$job_status"
}

echo "${0} - INTIALIZING MODULE 1"
job_start_time=$(date '+%Y-%m-%d_%H:%M:%S')
echo "${0} - Checking For other Process"

# 1) Checking running instance of the application
if [ -z "$(ls -A $localpath/temp)" ];
then
   echo "${0} - Application module 1 instance running in progress"
   touch $localpath/temp/_INPROGRESS
    if [ $? -eq 0 ];
    then
        #2) Functionality - Iterate over every json file and run a spark-submit job
        echo "${0} - Initializing the conversion JSON TO CSV"
        # Unsetting the jupyter-notebook related environment variables
        # source bash unset.sh
        unset PYSPARK_DRIVER_PYTHON
        unset PYSPARK_DRIVER_PYTHON_OPTS
        # Run conversion.py using Spark submit
        spark-submit --master yarn --deploy-mode cluster --driver-java-options -Dlog4j.configuration=file:///home/talentum/spark/conf/log4j.properties --conf "spark.executor.extraJavaOptions=-Dlog4j.configuration=file:///home/talentum/spark/conf/log4j.properties" --driver-memory 2g --num-executors 2 --executor-memory 1g ~/zomato_etl/spark/py/conversion.py $file_path
        echo "${0} - Conversion done"
        if [ $? -eq 0 ];
        then
            echo "${0} - Loading CSV to the HDFS Location"
            hdfs dfs -put $localpath/source/csv/zomato* /user/talentum/zomato_etl_group_no_6/zomato_ext/raw_zomato/ > /dev/null 2>&1
            if [ $? -eq 0 ];
            then
            #3) Functionality Preparing log message
            # Log end of module 1
                job_step="module_1"
                spark_submit_command="spark-submit --master yarn --deploy-mode cluster --driver-memory 2g --num-executors 2 --executor-memory 1g ~/zomato_etl/spark/py/conversion.py"
                job_status="SUCCESS"
                loc_job_end_time=$(date '+%Y-%m-%d_%H:%M:%S')
                log_job_status "$job_step" "$spark_submit_command/conversion.py" "$job_start_time" "$loc_job_end_time" "$job_status"
                echo "${0} - MODULE 1 COMPLETED"
            else
                echo "${0} - Loading Failed"
                log_failure  
                echo "${0} - logging the status"
            fi    
        else
            echo "${0} - Spark Application Failed"
            log_failure
            echo "${0} - Logging the status"
        fi
    else 
        echo "${0} - Files Required is Missing in Staging area"
        log_failure
        echo "${0} - Logging the status"   
    fi
    echo "${0} - Moving the JSON files to Archive"
    mv $localpath/source/json/* $localpath/archive
    rm $localpath/temp/*
else
    echo "${0} - Another process is running"
    log_failure
fi
echo "${0} - Module 1 stopped"
if [ $? -eq 0 ];
then
    #5) Functionality- Loading the log file from local file system to Hive table default.zomato_summary_log
    beeline -u jdbc:hive2://localhost:10000/$HIVE_DB -n $HIVE_USER -p $HIVE_PASS --hivevar dbname=$HIVE_DB -f $localpath/hive/ddl/createLogTable.hive > /dev/null 2>&1 
    beeline -u jdbc:hive2://localhost:10000/$HIVE_DB -n $HIVE_USER -p $HIVE_PASS --hivevar log=$localpath/logs/* -f $localpath/hive/dml/loadZomatoSummaryLog.hive
else
echo "${0} - Logging Failed"
fi