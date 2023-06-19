# Author:Akash M, Chaitanya S. Chichmalkar, Ayushi Trivedi, Rutul Deshmukh, Srivatsav Mallavarapu 

# Created date:07/05/2023 

# Modified date: 09/05/2023

# Description: This Scripts creates a new HDFS location if its already exist it will backup it 

# Usage: Concerion of JSON TO CSV

create_hdfs_directories() {
  echo "${0} - hdfsdir.sh STARTED"
  echo "${0} - Creating HDFS Directories"

  backup_dir_name="zomato_etl_group_no_6_$(date +'%Y%m%d_%H%M%S')"
  # Create backup directory if it doesn't exist
  if ! hdfs dfs -test -d zomato_etl_group_no_6_backup > /dev/null 2>&1 ; then
    hdfs dfs -mkdir zomato_etl_group_no_6_backup > /dev/null 2>&1 
  fi
  # Check if directory exists and backup/delete if it does
  if hdfs dfs -test -d zomato_etl_group_no_6 > /dev/null 2>&1 ; then
    # Make backup of existing directory
    echo "${0} - Backing up existing zomato_etl_group_no_6 directory to $backup_dir_name"
    hdfs dfs -cp -p zomato_etl_group_no_6 zomato_etl_group_no_6_backup/$backup_dir_name 
    # Delete existing directory
    echo "${0} - Deleting existing zomato_etl_group_no_6 directory"
    hdfs dfs -rm -r zomato_etl_group_no_6 > /dev/null 2>&1 
  fi
  # Create directories in HDFS
  echo "${0} - Creating new directories"
  
  hdfs dfs -mkdir -p zomato_etl_group_no_6/log > /dev/null 2>&1 
  hdfs dfs -mkdir -p zomato_etl_group_no_6/zomato_ext/zomato > /dev/null 2>&1 
  hdfs dfs -mkdir -p zomato_etl_group_no_6/zomato_ext/dim_country > /dev/null 2>&1 
  hdfs dfs -mkdir -p zomato_etl_group_no_6/zomato_ext/raw_zomato > /dev/null 2>&1 
}

# Call the functions 
create_hdfs_directories

