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
import pymongo
import random
import redis
import urllib
import codecs

conn = pymongo.MongoClient("mongodb://admin:Kr123$^@localhost:27017")
db = conn.member
col = db.memberinfo
col2 = db.memberinfo

r = redis.StrictRedis(password='Kr123456')

KEY_TOKEN_NAME_ID = "R:tni:%s:%s:%s"
KEY_TOKEN_NAME_ID_VID_SOURCE = "R:tnivs:%s:%s:%s:%s:%s"
KEY_TOKEN_VID = "R:token:%s:%s"
KEY_MEMBERINFO = "R:minfo:%s"
KEY_MEMBERINFO_TOKENID = 'tid%s'
progress = 0

infolist = list()
progress = 0

result = col.find()
total = result.count()
for memberinfo in result:
    progress+= 1
    if progress%1000 == 0:
        print '------------progress[%s/%s] ----------------' % (progress, result.count())

    if 'headimg' in memberinfo:
        headimglist = memberinfo['headimg'].split('/')
        if len(headimglist)<2:
            print '=================================='
            print memberinfo['username']
            col2.update({'_id':memberinfo['_id']},{'$set':{'headimg':'','headimg_fmt':''}})
            memberkey = KEY_MEMBERINFO %(memberinfo['_id'].__str__())
            if r.exists(memberkey):
                print memberkey
                r.hmset(memberkey,{'headimg':'','headimg_fmt':''})
        else:
            fileurl = '/mnt/www/html/ronaldo/image/%s/%s' % (headimglist[-2],headimglist[-1])
            if os.path.isfile(fileurl) is False:
                print '=================================='
                print memberinfo['username']
                col2.update({'_id':memberinfo['_id']},{'$set':{'headimg':'','headimg_fmt':''}})
                memberkey = KEY_MEMBERINFO %(memberinfo['_id'].__str__())
                if r.exists(memberkey):
                    print memberkey
                    r.hmset(memberkey,{'headimg':'','headimg_fmt':''})







