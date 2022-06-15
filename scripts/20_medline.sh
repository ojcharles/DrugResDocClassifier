#!/bin/bash
# this handles downloading, verifying, and parsing the pubmed database
# returns two parquet file in 
# data/raw_medline.parquet          - intermediate
# data/medline_lastview.parquet     - used here

echo "##### 2 - download data #####"


### downlaod all medline data and validate
# baseline
cd data/medline/baseline

wget -nc -c ftp://ftp.ncbi.nlm.nih.gov/pubmed/baseline/*.gz  #-nc noclobber, skips downloaded

# check downloads are valid
for f in ` ls *.gz  `
do
    echo local
    md5_local=(` md5sum $f `)
    md5_local=${md5_local[0]}
    echo ${md5_local}

    echo server
    wget -nc -c -q ftp://ftp.ncbi.nlm.nih.gov/pubmed/baseline/${f}.md5
    md5_server=(`cat ${f}.md5`)
    md5_server=${md5_server[1]}
    echo $md5_server
    rm ${f}.md5

    # if md5 checksums are identical do nothing, otherwise re-download
    if [ "$md5_local" = "$md5_server" ]; then
        echo "Strings are equal."
    else
        echo "Strings are not equal."
        echo "redownloading file"
        wget -nc -c -q ftp://ftp.ncbi.nlm.nih.gov/pubmed/baseline/${f}
    fi
done



# updatefiles
cd ../updatefiles
wget -nc -c ftp://ftp.ncbi.nlm.nih.gov/pubmed/updatefiles/*.gz
for f in ` ls *.gz  `
do
    md5_local=(` md5sum $f `)
    md5_local=${md5_local[0]}

    wget -nc -c -q ftp://ftp.ncbi.nlm.nih.gov/pubmed/updatefiles/${f}.md5
    md5_server=(`cat ${f}.md5`)
    md5_server=${md5_server[1]}
    rm ${f}.md5

    echo $f 
    echo ${md5_local}
    echo $md5_server

    # if md5 checksums are identical do nothing, otherwise re-download
    if [ "$md5_local" = "$md5_server" ]; then
        echo "Strings are equal."
    else
        echo "Strings are not equal."
        echo "redownloading file"
        rm $f
        wget -q ftp://ftp.ncbi.nlm.nih.gov/pubmed/updatefiles/${f}
    fi
done


cd ../../.. # back to drugresclassifier

# now that both baseline and update files are validated lets generate the rdd
spark-submit --driver-memory 20G scripts/21_medline.py > logs/21_medline.py.log 2>&1 &

# update
spark-submit --driver-memory 20G scripts/22_medline.py > logs/22_medline.py.log 2>&1 &
