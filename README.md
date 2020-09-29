# PKDocClassifier
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/fgh95/PKDocClassifier/blob/master/LICENSE)

This repository contains custom pipes and models to classify scientific publications from PubMed depending on whether they report new pharmacokinetic (PK) parameters from _in vivo_ studies. The final pipeline retrieved more than 120K PK publications and runs weekly updates. The documents retrieved by the pipeline have been made accessible at https://app.pkpdai.com/. 

# Reproducing our results

## 1. Installing dependencies 

You will need an environment with **Python 3.7 or greater**. We strongly recommend that you use an isolated Python environment (such as virtualenv or conda) to install the packages related to this project. Our default option will be to create a virtual environment with conda:
    
1. If you don't have conda follow the instructions [here](https://conda.io/projects/conda/en/latest/user-guide/install/index.html?highlight=conda#regular-installation)

2. Run 

    ````
   conda create -n PKDocClassifier python=3.7
    ````

3. Activate it through
    ````
   source activate PKDocClassifier
    ````

Then, clone and access this repository on your local machine through:

````
git clone https://github.com/fgh95/PKDocClassifier
cd PKDocClassifier
````
If you are on MacOSX run: 

````
brew install libomp
````

Install all dependencies by running: 

````
pip install .
````

## 2. Data download - Optional

If you would like to reproduce the steps taken for data retrieval and parsing you will need to download the whole MEDLINE dataset and store it into a spark dataframe. 
However, you can also skip this step and use the parsed data available at [data/subsets/](https://github.com/fgh95/PKDocClassifier/tree/master/data/subsets). Alternatively, follow the steps at [pubmed_parser wiki](https://github.com/titipata/pubmed_parser/wiki/Download-and-preprocess-MEDLINE-dataset) and place the resulting `medline_lastview.parquet` file at _data/medline_lastview.parquet_. Then, change the [spark config file](https://github.com/fgh95/PKDocClassifier/blob/master/sparksetup/sparkconf.py) to your spark configuration and run:

````
python getready.py
````

This should generate the files at [data/subsets/](https://github.com/fgh95/PKDocClassifier/tree/master/data/subsets).

## 3. Run

### 3.1. Field analysis and ngrams

1. To generate the features run (~30min):

````
python features_bow.py
````

2. Bootstrap field analysis (~3h on 12 threads, requires at least 16GB of RAM)

````
python bootstrap_bow.py \
    --input-dir data/encoded/fields \
    --output-dir data/results/fields \
    --output-dir-bootstrap data/results/fields/bootstrap \
    --path-labels data/labels/dev_data.csv
````

3. Bootstrap n-grams (~3h on 12 threads, requires at least 16GB of RAM)

````
python bootstrap_bow.py \
    --input-dir data/encoded/ngrams \
    --output-dir data/results/ngrams \
    --output-dir-bootstrap data/results/ngrams/bootstrap \
    --path-labels data/labels/dev_data.csv
````

4. Display results

````
python display_results.py \
    --input-dir  data/results/fields\
    --output-dir data/final/fields
````

````
python display_results.py \
    --input-dir  data/results/ngrams\
    --output-dir data/final/ngrams
````




