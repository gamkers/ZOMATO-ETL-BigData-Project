#!/bin/bash

# Author:Akash M, Chaitanya S. Chichmalkar, Ayushi Trivedi, Rutul Deshmukh, Srivatsav Mallavarapu 

# Created date:07/05/2023 
# Modified date: 09/05/2023

# Prerequisite:
# 1) Hadoop services are running
# 2) Your home folder is there on HDFS, Hive ware house is set on hdfs to /user/hive/warehouse
# 3) Hive metastore and Hiveserver2 services are running
# 4) A setLocalPath.sh run successfully
# 5) To send mail you have to configure mail api in your system

# Description: This script is the starting point of the project workflow.
# Usage: ./wrapper.sh

source /home/talentum/zomato_etl/scripts/zomato.properties

echo "${0} - SETTING UP PROJECT ENVIRONMENT"
# 1) Running a script for setting up project/application environment
bash $localpath/scripts/setup.sh
if [ $# -eq 0 ]
then
    # Run all modules
    # 1) Runnig a script representing module 1 activities (module_1.sh)
    bash $localpath/scripts/module1.sh 
    if [ $? -eq 0 ]
    then
        # 2) Runnig a script representing module 2 activities (module_1.sh)
        bash $localpath/scripts/module2.sh
    else
        echo "${0} - module1 failed"
        exit 1
    fi
elif [ $1 -eq 1 ]
then
    # Run module 1
    #2) Runnig a script representing module 1 activities (module_1.sh)
    bash $localpath/scripts/module1.sh
    if [ $? -eq 0 ]
    then 
    echo "${0} - MODULE 1 EXECUTED SUCCESSFULY"
    else
    echo "${0} - MODULE 1 FAILED"

    fi

elif [ $1 -eq 2 ]
then
    # Run module 2
    # 3) Runnig a script representing module 2 activities (module_1.sh)
    bash $localpath/scripts/module2.sh
    if [ $? -eq 0 ]
    then 
    echo "${0} - MODULE 2 EXECUTED SUCCESSFULY"
    else
    echo "${0} - MODULE 2 FAILED"
    fi
else
    echo "${0} - Invalid argument. Usage: ./wrapper.sh [1|2]"
fi
