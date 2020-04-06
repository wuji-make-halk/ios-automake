#!/usr/bin python
# -*- coding: UTF-8 -*-
# filename:  getserviceinfo.py
# creator:   jacob.qian
# datetime:  2013-5-31
# holly 公共模块，发送http信息


# import urllib
import pymongo
import sys
import httplib2
import json
# import base64
import logging
# import time
import logging.config
logging.config.fileConfig("/opt/Clousky/Ronaldo/server/conf/log.conf")
import MySQLdb as mysql
import json
import time
import uuid
from urllib import unquote
import hashlib
import Queue
# queue = Queue()
import thread
import random
import datetime

def ex(cursor, sqlstr):
    print 'execut [%r]'%(sqlstr)
    return cursor.execute(sqlstr)

def calcpassword(password):
    m0 = hashlib.md5("abcdef")
#        print m0.hexdigest()
    m1 = hashlib.md5(password.encode('utf-8') + m0.hexdigest())
#        print m1.hexdigest()
    md5password = m1.hexdigest()
    return md5password

def importuser():
#    try:
    fileobj = open('/opt/Clousky/Ronaldo/server/conf/db.conf', 'r')
    json_dbcfg = json.load(fileobj)
    fileobj.close()

    conn = mysql.connect(host=json_dbcfg['host'], user=json_dbcfg['user'], passwd=json_dbcfg[
                         'passwd'], db=json_dbcfg['dbname'], charset=json_dbcfg['charset'])
    cursor = conn.cursor(cursorclass=mysql.cursors.DictCursor)
    mongoconn = pymongo.Connection(json_dbcfg['mongo_ip'],int(json_dbcfg['mongo_port'],password=json_dbcfg['redispassword']))
#    _redis = redis.StrictRedis(json_dbcfg['redisip'], int(json_dbcfg['redisport']))
    db = mongoconn.member
    collection = db.memberinfo



    count = cursor.execute("SELECT * from tbl_user")
    rows = cursor.fetchall()
    i = 0
    for row in rows:
        for key in row:
            if row[key] is None:
                row[key] = ''
        if collection.find_one({'username':row['user_name']}):
            print "meber %s already exist" % (row['user_name'])
            continue

        insertmember = dict({\
            'username':row['user_name'],\
            'nickname':row['user_name'],\
            'password':calcpassword(row['password']),\
            'vid':'00001001001',\
            'createtime': datetime.datetime.now(),\
            'lastlogintime':None,\
            'lastlong':None,\
            'lastlat':None,\
            'state': 0,\
            'mobile':row['phone'],\
            'email':row['user_name'],\
            'friends':list(),\
            'users':list()\
            })
        print insertmember
        print collection.insert_one(insertmember)
        i += 1


    print 'total %d record' % i




    cursor.close()
    conn.close()
    return
#    except Exception as e:
#        print ("%s except raised : %s " % (e.__class__, e.args))
#        return 0



if __name__ == "__main__":
    ''' parm1: moduleid,
    '''

    importuser()
    while 1:
    	time.sleep(1)
