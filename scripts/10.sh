#!/bin/bash
# this handles installing dependencies

echo "##### 1 - install dependencies #####"

### for non GPU stuff

# if conda env does not exist, installs
conda_env_exists=`conda env list | grep DrugResClassifier`
if [ ${#conda_env_exists} -le 5 ] ; then 
   echo "Conda environment DrugResClassifier not found, installing";
   # source create -n DrugResClassifier python=3.7
   #pip install .
else
   echo "conda env fine";
fi



### for GPU attention models
conda_env_exists=`conda env list | grep bert`
if [ ${#conda_env_exists} -le 5 ] ; then 
   echo "Conda environment bert not found, installing";
   conda create --name specter python=3.7 setuptools 
   source activate specter 
   conda install pytorch cudatoolkit=10.1 -c pytorch    
   #install specter with biobert
   git clone git@github.com:allenai/specter.git
   cd specter
   wget https://ai2-s2-research-public.s3-us-west-2.amazonaws.com/specter/archive.tar.gz
   tar -xzvf archive.tar.gz 
   pip install -r requirements.txt  
   python setup.py install
   cd ..
   echo "Conda env bert installed"
else
   echo "conda env fine";
fi