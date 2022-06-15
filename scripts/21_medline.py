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

# stage 1 -this is simply assigning files to each executor
medline_files_rdd = spark.sparkContext.parallelize(glob('data/medline/*/*.gz', recursive=True), numSlices=25)

# stage 2 - this is super fast
parse_results_rdd = medline_files_rdd.\
    flatMap(lambda x: [Row(file_name=os.path.basename(x), **publication_dict) 
                       for publication_dict in pp.parse_medline_xml(x)])

# stage 3 - this takes time and is actually what we want to parquet
medline_df = parse_results_rdd.toDF()

# stage 4 - save to parquet
medline_df.write.parquet('raw_medline.parquet', mode='overwrite')



