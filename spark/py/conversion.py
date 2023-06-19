from datetime import datetime, timedelta
import os
from pyspark.sql import SparkSession
import pyspark.sql.functions as F
import logging
import sys

if __name__ =='__main__':
    spark = SparkSession.builder.master('yarn').enableHiveSupport().getOrCreate()
    sc = spark.sparkContext

    # Defining Logger
    log4jLogger = sc._jvm.org.apache.log4j
    logger = log4jLogger.LogManager.getLogger("jsontocsv")

    try:
        print("--------------------------------------Hello, Group_no_6 member-----------------------------------------------")
        # Set the file path for the JSON files
        file_path = sys.argv[1] #TO DO HAVE VAR
        #file_path = "$1"
        # Date Incrementation
        date_increment = datetime.now().date()
        # Reading and writing files
        file_path_loop = os.listdir(file_path)
        if len(file_path_loop) != 0:
            for idx, file_name in enumerate(sorted(file_path_loop)):
                order_number = idx + 1
                print("CONVERTED {} to CSV FORMAT".format(file_name))
                df = spark.read.format("json").option("inferSchema", "true").load(
                    "file:///home/talentum/zomato_etl/source/json/{}".format(file_name))
                new_df = df.select(F.explode(df.restaurants.restaurant)) #
                logger.info(new_df.printSchema())
                final_df = new_df.select(new_df.col.R.res_id.alias('Restaurant_ID'),
                                         new_df.col['name'].alias('Restaurant_Name'),
                                         new_df.col.location.country_id.alias('Country_Code'),
                                         new_df.col.location.city.alias("City"),
                                         new_df.col.location.address.alias('Address'),
                                         new_df.col.location.locality.alias('Locality'),
                                         new_df.col.location.locality_verbose.alias('Locality_Verbose'),
                                         new_df.col.location.longitude.alias('Longitude'),
                                         new_df.col.location.latitude.alias('Latitude'),
                                         new_df.col.cuisines.alias("Cuisines"),
                                         new_df.col.average_cost_for_two.alias("Average_Cost_For_Two"),
                                         new_df.col.currency.alias("Currency"),
                                         new_df.col.has_table_booking.alias("Has_Table_Booking"),
                                         new_df.col.has_online_delivery.alias("Has_Online_Delivery"),
                                         new_df.col.is_delivering_now.alias("Is_Delivering_Now"),
                                         new_df.col.switch_to_order_menu.alias("Switch_To_Order_Menu"),
                                         new_df.col.price_range.alias("Price_Range"),
                                         new_df.col.user_rating.aggregate_rating.alias("Aggregate_Rating"),
                                         new_df.col.user_rating.rating_text.alias("Rating_Text"),
                                         new_df.col.user_rating.votes.alias("Votes")
                                         )
                final_df.write.format('csv').options(delimiter='\t').save(
                    'file:///home/talentum/zomato_etl/source/csv/{}'.format(file_name))
                os.system(
                    'mv /home/talentum/zomato_etl/source/csv/{}/part* /home/talentum/zomato_etl/source/csv/zomato_{}'.format(
                        file_name,
                        str(date_increment)))
                date_increment = date_increment + timedelta(1)
        else:
            print("NO FILES FOUND FOR CONVERSION. KINDLY UPLOAD DATA FIRST!")
            pass
    except(IOError, IndexError, EOFError):
        print("FAILED")
    else:
        print("SUCCESSFUL")
    os.system('rm -rf /home/talentum/zomato_etl/source/csv/*.json')

 