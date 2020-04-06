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
db = conn.datacenter
col = db.fitness

r = redis.StrictRedis(password='Kr123456')

KEY_TOKEN_NAME_ID = "R:tni:%s:%s:%s"
KEY_TOKEN_NAME_ID_VID_SOURCE = "R:tnivs:%s:%s:%s:%s:%s"

infolist = list()
result = col.find()
for fitnessinfo in result:
    updatedict = dict()
    if 'datestr' not in fitnessinfo and 'datatime' in fitnessinfo:
        updatedict['datestr'] = fitnessinfo['datatime'].split("T")[0]
        updatedict['datetimestr'] = fitnessinfo['datatime']
        updatedict['datetime'] = datetime.datetime.strptime(fitnessinfo['datatime'],'%Y-%m-%dT%H:%M:%S')
    if 'datestr' not in fitnessinfo and 'datetime' in fitnessinfo:
        updatedict['datestr'] = fitnessinfo['datetime'].strftime('%Y-%m-%dT%H:%M:%S').split("T")[0]
        updatedict['datetimestr'] = fitnessinfo['datetime'].strftime('%Y-%m-%dT%H:%M:%S')
        
    print updatedict
    if len(updatedict):
        col.update_one({'_id':fitnessinfo['_id']},{'$set':updatedict})


