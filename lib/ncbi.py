#!/usr/bin/python

import os
import urllib
import urllib2

def fetch_genome (name, outdir):
    url='https://ftp.ncbi.nlm.nih.gov/genomes/%s/GFF/' % name
    page=urllib.urlopen(url)
    strpage=page.read().split('\n')
    name_files=[]
    for i in range(len(strpage) -1):
        if "404 Not Found" in strpage[i]:
            rep='Le genome de l\'espece %s n\'a pas ete trouve' % name
            return rep
        if "top_level" in strpage[i] and "ref_" in strpage[i]:
            name_files.append(strpage[i])
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    strfile=name_files[0].split('href="')[1].split('">')[0]
    u = urllib2.urlopen('%s/%s' % (url, strfile))
    f = open('%s/%s' % (outdir, strfile) , 'wb')
    meta = u.info()
    file_size = int(meta.getheaders("Content-Length")[0])
    print "Downloading: %s Bytes: %s" % (strfile, file_size)
    file_size_dl = 0
    block_sz = 8192
    while True:
        buffer = u.read(block_sz)
        if not buffer:
            break
        file_size_dl += len(buffer)
        f.write(buffer)
        status = r"%10d  [%3.2f%%]" % (file_size_dl, file_size_dl * 100. / file_size)
        status = status + chr(8)*(len(status)+1)
        print status,
    f.close()
