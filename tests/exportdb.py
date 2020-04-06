import sys
import os
import socket
import struct
import hashlib
import binascii
import time
import datetime
import select
import pymongo
import random
import redis
import urllib
import codecs

conn = pymongo.MongoClient("mongodb://admin:Kr123$^@localhost:27017")
db = conn.member
col = db.memberinfo


remoteconn = pymongo.MongoClient("mongodb://admin:Kr123$^@120.24.238.189:27017")
remotedb = remoteconn.member
remotecol = remotedb.memberinfo


r = redis.StrictRedis(password='Kr123456')
remoter = redis.StrictRedis(host='120.24.238.189',password='Kr123456')


KEY_TOKEN_NAME_ID = "R:tni:%s:%s:%s"
KEY_TOKEN_NAME_ID_VID_SOURCE = "R:tnivs:%s:%s:%s:%s:%s"
KEY_TOKEN_VID = "R:token:%s:%s"
KEY_MEMBERINFO = "R:minfo:%s"
KEY_MEMBERINFO_TOKENID = 'tid%s'
progress = 0

#resultlist = r.keys(KEY_TOKEN_NAME_ID%('*','*','*'))
#total = len(resultlist)
#redisdict = dict()
#for key in resultlist:
#    progress+= 1
#    if progress%1000 == 0:
#        print '------------proc redis key progress[%s/%s] ----------------' % (progress, total)
#    tokeninfo = r.hgetall(key)
#    remoter.hmset(key,tokeninfo)



progress = 0

result = col.find()
total = result.count()
insertlist = list()
for memberinfo in result:
    progress+= 1
    if progress%1000 == 0:
        print '------------proc db key progress[%s/%s] ----------------' % (progress, total)
        remotecol.insert_many(insertlist)
        insertlist = list()
    insertlist.append(memberinfo)
if len(insertlist):
    remotecol.insert_many(insertlist)


