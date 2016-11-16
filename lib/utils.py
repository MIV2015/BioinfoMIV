#!/usr/bin/python

import os
import zipfile
import gzip


def unzip (input, output):
    zip_ref = zipfile.ZipFile(input, 'r')
    zip_ref.extractall(output)
    zip_ref.close()


def gunzip (input,output):
    inF = gzip.open(input, 'rb')
    outF = open(output, 'wb')
    outF.write( inF.read() )
    inF.close()
    outF.close()
