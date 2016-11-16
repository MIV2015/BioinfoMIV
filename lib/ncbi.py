#!/usr/bin/python

import os
import urllib

def fetch_genome (name, outdir):
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    url_ncbi='https://ftp.ncbi.nlm.nih.gov/genomes/%s/GFF/' % name
    page=urllib.urlopen(url_ncbi)
    strpage=page.read().split('\n')
    name_files=[]
    for i in range(len(strpage) -1):
        if "top_level" in strpage[i] and "ref_" in strpage[i]:
            name_files.append(strpage[i])
    strfile=name_files[0].split('href="')[1].split('">')[0]
    urllib.urlretrieve('%s/%s' % (url_ncbi, strfile), '%s/%s' % (outdir, strfile))
