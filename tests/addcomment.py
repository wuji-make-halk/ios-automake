#!/usr/bin/python
# -*- coding: UTF-8 -*-
# SMGP v3.0 api file
import sys
import os
import socket
import struct
import hashlib
import binascii
import time
import datetime
import select
import redis
import codecs


if __name__ == "__main__":
    ''' param1 filename,
        param2 snsid(O)
    '''
    filename = sys.argv[1]
    if sys.argv[2]:
    	snsid = sys.argv[2]
    else:
    	snsid = None
    r = redis.StrictRedis()
    f=codecs.open(filename,'r','utf-8')

    if snsid is None:
        key = 'tyrant:comment:set'
        c = f.readlines()
        for d in c:
            print d
            r.sadd(key, d.replace('\r','').replace('\n',''))
    else:
    	key = 'tyrant:comment:set:%s' % (snsid)
#    	r.delete(key)
        c = f.readlines()
        for d in c:
            print d
            r.sadd(key, d.replace('\r','').replace('\n',''))

    f.close()


