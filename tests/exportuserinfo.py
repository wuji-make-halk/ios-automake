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


infolist = list()
result = col.find()
for memberinfo in result:
    username = memberinfo.get('username')
    email = memberinfo.get('email')
    source = "origin"
    if memberinfo.get('source') is not None:
        source = memberinfo.get('source')
    gender = ""
    height = ""
    device = ""
    weight = ""
    name = ""
    stride = ""
    gobed = ""
    unit = ""
    uaauth = ""
    vaauth = ""
    birth = ""
    goalstep = ""
    challenge = ""
    userlist = memberinfo.get('users')
    if len(userlist):
        userinfo = userlist[0]
        if userinfo.get('name') is not None:
            name = userinfo.get('name')
        if userinfo.get('height') is not None:
            if isinstance(userinfo.get('height'), str):
                height = userinfo.get('height')
            else:
                if isinstance(userinfo.get('height'), unicode):
                    height = userinfo.get('height').encode('utf-8')
                else:
                    height = "%.1f" % (userinfo.get('height'))
        if userinfo.get('weight') is not None:
            if isinstance(userinfo.get('weight'), str):
                weight = userinfo.get('weight')
            else:
                if isinstance(userinfo.get('weight'), unicode):
                    weight = userinfo.get('weight').encode('utf-8')
                else:
                    weight = "%.1f" % (userinfo.get('weight'))
#            weight = "%r" % (userinfo.get('weight'))
        if userinfo.get('stride') is not None:
            if isinstance(userinfo.get('stride'), str):
                stride = userinfo.get('stride')
            else:
                if isinstance(userinfo.get('stride'), unicode):
                    stride = userinfo.get('stride').encode('utf-8')
                else:
                    stride = "%.1f" % (userinfo.get('stride'))
#            stride = "%r" % (userinfo.get('stride'))
        if userinfo.get('gobed_hour') is not None:
            gobed = "%d" % (userinfo.get('gobed_hour'))
        if userinfo.get('goal_steps') is not None:
            goalstep = "%d" % (userinfo.get('goal_steps'))
        if userinfo.get('yoo_challenge') is not None:
            challenge =urllib.unquote(userinfo.get('yoo_challenge').encode('utf-8'))
        if userinfo.get('ua_auth') is not None:
            if isinstance(userinfo.get('ua_auth'), str):
                uaauth = userinfo.get('ua_auth')
            else:
                uaauth = str(userinfo.get('ua_auth'))
        if userinfo.get('validic_authrozie') is not None:
            if isinstance(userinfo.get('validic_authrozie'), str):
                vaauth = userinfo.get('validic_authrozie')
            else:
                vaauth = str(userinfo.get('validic_authrozie'))
        if userinfo.get('gear_subtype') is not None:
            device = userinfo.get('gear_subtype')
        tmp = userinfo.get('unit')
        if tmp == 1:
            unit = 'metric'
        else:
            unit = 'us'
        tmp = userinfo.get('gender')
        if tmp == '1':
            gender = 'male'
        else:
            gender = 'female'

    mi = list()
    mi.append(source)
    mi.append(username)
    mi.append(email)
    mi.append(name)
    mi.append(birth)
    mi.append(gender)
    mi.append(height)
    mi.append(weight)
    mi.append(stride)
    mi.append(unit)
    mi.append(device)
    mi.append(gobed)
    mi.append(uaauth)
    mi.append(vaauth)
    mi.append(goalstep)
    mi.append(challenge)
#   print mi
    string = '|'.join(mi)
    print string
    infolist.append(string)


fb = codecs.open('/opt/userinfo.txt', "w", "utf-8")
#fb = open('/opt/userinfo.txt','w')
flushstring = '\n'.join(infolist)
fb.write(flushstring)
fb.close()










