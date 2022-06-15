#!/bin/bash
# this is a bash script that completely runs the doc classifier pipeline as in readme
# Oscar Charles 2022


#qrsh -l tmem=6g,h_vmem=6g -pe smp 26

# activate conda
source /share/apps/anaconda/bin/activate
# dir
cd /SAN/breuerlab/pathseq1/oc/DrugResDocClassifier


# runtime vars
#threads=26 # we assume 26 threads for now





########## 1. installing dependencies
source scripts/10.sh
# activate env
source activate DrugResClassifier





########## 2 - download data
# produce a parquet of all medline documents
source scripts/20_medline.sh

# take the provided document classes and produce train/test data
python scripts/get_ready.py    # fails if multi-node





########## 3 - analysis by ngram
### 3.1 ngram
# 3.1.1 format data for ngram classifier
python scripts/features_bow.py

# 3.1.2 fields analysis - skipping, v slow and buggy

# 3.1.3 Bootstrap n-grams (set overwrite to False if you want to skip this step)
python scripts/bootstrap_bow.py \
   --input-dir data/encoded/ngrams \
   --output-dir data/results/ngrams \
   --output-dir-bootstrap data/results/ngrams/bootstrap \
   --path-labels data/labels/training_labels.csv \
   --overwrite True

# with idf. i.e ngram of 1 --use_idf is tfidf
python scripts/bootstrap_bow.py \
   --input-dir data/encoded/ngrams \
   --output-dir data/results/ngrams-idf \
   --output-dir-bootstrap data/results/ngrams/bootstrap-idf \
   --path-labels data/labels/training_labels.csv \
   --overwrite True \
   --use-idf True

# 3.1.4 display results
python scripts/display_results.py \
   --input-dir  data/results/ngrams\
   --output-dir data/final/ngrams

python scripts/display_results.py \
   --input-dir  data/results/ngrams-idf\
   --output-dir data/final/ngrams-idf

### 3.2. Distributed representations
# this requires a GPU environment
source deactivate
exit

qrsh -l tmem=64G,gpu=true,h_rt=3600 -pe gpu 1
source activate bert
# 3.2.1 specter
# skip as this was really expensive to run and eh



### 3.2.2 biobert






# alter python scripts/get_ready.py
# remove specific entry from pubmedparser

### step 2 - ML attention model - GPU intensive

#qrsh -l tmem=64G,gpu=true,h_rt=3600 -pe gpu 1


"""
git clone git@github.com:allenai/specter.git

cd specter

wget https://ai2-s2-research-public.s3-us-west-2.amazonaws.com/specter/archive.tar.gz

tar -xzvf archive.tar.gz 


# cuda
export PATH=$PATH:/share/apps/cuda-10.2/bin/


pip install -r requirements.txt  

python setup.py install
"""