import os
from glob import glob
import pubmed_parser as pp
from pyspark.sql import SparkSession
from pyspark.sql import Row

from pyspark import sql
spark = (
    sql.SparkSession.builder.master("local[25]")
    .config("spark.executor.memory", "3g")
    .config("spark.driver.memory", "20g")
    .getOrCreate()
)


# stage 5 - update the file
medline_df = spark.read.parquet('data/raw_medline.parquet')

from pyspark.sql import Window
from pyspark.sql.functions import rank, max, sum, desc

window = Window.partitionBy(['pmid']).orderBy(desc('file_name'))

windowed_df = medline_df.select(
    max('delete').over(window).alias('is_deleted'),
    rank().over(window).alias('pos'),
    '*')

windowed_df.where('is_deleted = False and pos = 1').\
    write.\
    parquet('data/medline_lastview.parquet', mode='overwrite')