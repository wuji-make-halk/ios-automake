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

resultlist = r.keys(KEY_TOKEN_NAME_ID%('*','*','*'))
total = len(resultlist)
redisdict = dict()
for key in resultlist:
    progress+= 1
    if progress%1000 == 0:
        print '------------proc redis key progress[%s/%s] ----------------' % (progress, total)
    memberid = key.split(':')[4]
    redisdict[memberid] = key


infolist = list()
progress = 0

result = col.find()
total = result.count()
for memberinfo in result:
    progress+= 1
    if progress%1000 == 0:
        print '------------progress[%s/%s] ----------------' % (progress, result.count())
#    t1 = time.time()
    updatedict = dict()
#    print '------------0------------------- %s' % (time.time()-t1)
    if 'username' in memberinfo:
        updatedict['username'] = memberinfo['username'].lower()
    else:
        print memberinfo
    if 'vid' not in memberinfo:
        vidlist = list()
        vidlist.append('000001001001')
        updatedict['vid'] = vidlist
    elif isinstance(memberinfo['vid'], list) is False:
        vidlist = list()
        vidtmp = memberinfo['vid']
        if len(vidtmp)<12:
            vidtmp = '000001001001'
        vidlist.append(vidtmp)
        updatedict['vid'] = vidlist
    else:
        vidlist = memberinfo['vid']

    if 'source' not in memberinfo:
        sourcelist = list()
        sourcelist.append('origin')
        updatedict['source'] = sourcelist
    elif isinstance(memberinfo['source'], list) is False:
        sourcelist = list()
        sourcelist.append(memberinfo['source'])
        updatedict['source'] = sourcelist
    else:
        sourcelist = memberinfo['source']

    for vid in vidlist:
        for source in sourcelist:
            passwordkey = 'password:%s:%s' % (source, vid)
            if passwordkey not in memberinfo:
               updatedict[passwordkey] = memberinfo['password']
#                updatedict[passwordkey] = '0b5ebdbe694c105a800f3d8b3d392189'

    userlist = memberinfo.get('users')
    if userlist is not None and len(userlist)>0:
        userinfo = userlist[0]
        updatedict.update(userinfo)

    follower = memberinfo.get('follower')
    if follower is None or isinstance(follower,dict) is False:
        follower = dict()

    friends = memberinfo.get('friends')
    if friends is None or isinstance(friends,dict) is False:
        friends = dict()
    
    for friendid in friends:
        tmpfriendinfo = friends[friendid]
        friendinfo = dict()
        if 'name' in tmpfriendinfo:
            friendinfo['remark'] = tmpfriendinfo['name']
        else:
            friendinfo['remark'] = ''
        friends[friendid] = friendinfo
        follower[friendid] = friendinfo
    if 'membertype' not in memberinfo:
        updatedict['friends'] = friends
        updatedict['follower'] = follower

        updatedict['membertype'] = 0
        updatedict['memberlevel'] = 1
        updatedict['memberexp'] = 0
        updatedict['memberpriority'] = 1
        updatedict['followtype'] = 0
        updatedict['step_share'] = 1
        updatedict['weight_share'] = 1
        updatedict['calories_share'] = 1
        updatedict['sleep_share'] = 1
        updatedict['nation'] = ""
        updatedict['nationcode'] = ''
        updatedict['province'] = ''
        updatedict['address'] = ''
        updatedict['contact'] = ''
        updatedict['zipcode'] = ''
        updatedict['introduce'] = ''

#    print "change memberinfo %r " % (updatedict)
#    print '------------1------------------- %s' % (time.time()-t1)
    if len(updatedict):
        pass
        col2.update_one({'_id':memberinfo['_id']},{'$set':updatedict})
    membertokendict = dict()
#    resultlist = r.keys(KEY_TOKEN_NAME_ID%('*','*',memberinfo['_id'].__str__()))
    resultlist = redisdict.get(memberinfo['_id'].__str__())
    if resultlist is not None:
        tnikey = resultlist
        keylist = tnikey.split(':')
        token = keylist[2]
        membername = keylist[3]
        memberid = keylist[4]
        vid = vidlist[0]
        source = sourcelist[0]
#        print "Delete Old key : %s" % (tnikey)
        r.delete(tnikey)
        newkey = KEY_TOKEN_VID % (token,vid)
#        print "Add New key : %s" % (newkey)
        tokendict = dict()
        tokendict['memberid'] = memberid
        tokendict['username'] = membername
        tokendict['tid'] = token
        tokendict['vid'] = vid
        tokendict['source'] = source
        r.hmset(newkey, tokendict)
        r.expire(newkey,15*24*60*60)

        membertokendict[KEY_MEMBERINFO_TOKENID%(vid)] = token

#    resultlist = r.keys(KEY_TOKEN_NAME_ID_VID_SOURCE % ('*', '*', memberinfo['_id'].__str__(), '*', '*'))
#    print '------------2------------------- %s' % (time.time()-t1)
#    if len(resultlist):
#        for tnikey in resultlist:
#            print tnikey
#            keylist = tnikey.split(':')
#            token = keylist[2]
#            membername = keylist[3]
#            memberid = keylist[4]
#            vid = keylist[5]
#            source = keylist[6]
#            print "Delete Old key : %s" % (tnikey)
##            r.delete(tnikey)
#            newkey = KEY_TOKEN_VID % (token,vid)
#            print "Add New key : %s" % (newkey)
#            tokendict = dict()
#            tokendict['memberid'] = memberid
#            tokendict['username'] = membername
#            tokendict['tid'] = token
#            tokendict['vid'] = vid
#            tokendict['source'] = source
##            r.hmset(newkey, tokendict)
#            membertokendict[KEY_MEMBERINFO_TOKENID%(vid)] = token

    currentmemberinfo = dict()
    currentmemberinfo.update(memberinfo)
    currentmemberinfo['_id'] = memberinfo['_id'].__str__()
    currentmemberinfo.update(updatedict)
    currentmemberinfo.update(membertokendict)
    if 'users' in currentmemberinfo:
        currentmemberinfo.pop('users')
    if 'alarms' in currentmemberinfo:
        currentmemberinfo.pop('alarms')
    if 'device' in currentmemberinfo:
        currentmemberinfo.pop('device')
    if 'createtime' in currentmemberinfo:
        currentmemberinfo.pop('createtime')

    memberinfonkey = KEY_MEMBERINFO % (memberinfo['_id'].__str__())
#    redismemberinfo = dict()
#    redismemberinfo.update(memberinfo)
#    redismemberinfo.update(membertokendict)
#    print '------------3------------------- %s' % (time.time()-t1)
#    print "Add MEMBERINFO key : %s" % (memberinfonkey)
#    print "Add MEMBERINFO value : %s" % (currentmemberinfo)
    if r.exists(memberinfonkey) is False:
        r.hmset(memberinfonkey, currentmemberinfo)






