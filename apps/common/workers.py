#!/usr/bin python
# -*- coding: UTF-8 -*-
# filename:  asset_main.py
# creator:   jacob.qian
# datetime:  2013-5-31
# Ronaldo wokers类的基类
import json
import random
import logging
import urllib
import os
import datetime
from bson.objectid import ObjectId
#import time

projectpath = os.getcwd()
import logging.config
logging.config.fileConfig(projectpath+"/conf/log.conf")
logr = logging.getLogger('ronaldo')





class WorkerBase():


    #errorcode define
    ERRORCODE_OK = "200"
    ERRORCODE_UNKOWN_CMD = "40000"



    def __init__(self, moduleid):
        try:
            logr.debug('WorkerBase::__init__')
            self._moduleid = moduleid
            fileobj = open('./conf/db.conf', 'r')
            self._json_dbcfg = json.load(fileobj)
            fileobj.close()

            fileobj = open('./conf/config.conf', 'r')
            self._config = json.load(fileobj)
            fileobj.close()

#            fileobj = open('/opt/Keeprapid/Ronaldo/server/conf/vid.conf', 'r')
#            self._vidconfig = json.load(fileobj)
#            fileobj.close()

            self._redis = None
            
        except Exception as e:
            logr.error("%s except raised : %s " % (e.__class__, e.args))

    def redisdelete(self, argslist):
        logr.debug('%s' % ('","'.join(argslist)))
        ret = eval('self._redis.delete("%s")'%('","'.join(argslist)))
        logr.debug('delete ret = %d' % (ret))

    def _sendMessage(self, to, body):
        #发送消息到routkey，没有返回reply_to,单向消息
#        logr.debug(to +':'+body)
        if to is None or to == '' or body is None or body == '':
            return

        self._redis.lpush(to, body)

    #递归调用，解析每一层可能需要urllib.unquote的地方
    def parse_param_lowlevel(self, obj):
        if isinstance(obj,dict):
            a =dict()
            for key in obj:
                if isinstance(obj[key],dict) or isinstance(obj[key],list):
                    a[key] = self.parse_param_lowlevel(obj[key])
                elif isinstance(obj[key],unicode) or isinstance(obj[key],str):
                    a[key] = urllib.unquote(obj[key].encode('utf-8')).decode('utf-8')
                else:
                    a[key] = obj[key]
            return a
        elif isinstance(obj,list):
            b = list()
            for l in obj:
                if isinstance(l, dict) or isinstance(l, list):
                    b.append(self.parse_param_lowlevel(l))
                elif isinstance(l,unicode) or isinstance(l,str):
                    b.append(urllib.unquote(l.encode('utf-8')).decode('utf-8'))
                else:
                    b.append(l)
            return b
        else:
            return obj

    #递归调用，解析每一层可能需要urllib.unquote的地方
    def packet_param_lowlevel(self, obj):
        if isinstance(obj,dict):
            a =dict()
            for key in obj:
                if isinstance(obj[key],dict) or isinstance(obj[key],list):
                    a[key] = self.packet_param_lowlevel(obj[key])
                elif isinstance(obj[key],unicode) or isinstance(obj[key],str):
                    a[key] = urllib.quote(obj[key].encode('utf-8'))
                elif isinstance(obj[key],datetime.datetime) or isinstance(obj[key],ObjectId):
                    a[key] = obj[key].__str__()
                else:
                    a[key] = obj[key]
            return a
        elif isinstance(obj,list):
            b = list()
            for l in obj:
                if isinstance(l, dict) or isinstance(l, list):
                    b.append(self.packet_param_lowlevel(l))
                elif isinstance(l,unicode) or isinstance(l,str):
                    b.append(urllib.quote(l.encode('utf-8')))
                elif isinstance(l,datetime.datetime) or isinstance(l,ObjectId):
                    b.append(obj[key].__str__())
                else:
                    b.append(l)
            return b
        elif isinstance(obj,unicode) or isinstance(obj,str):
            return urllib.quote(obj.encode('utf-8'))
        elif isinstance(obj,datetime.datetime) or isinstance(obj,ObjectId):
            return obj.__str__()
        else:
            return obj

    #给OpenApi平台推送数据
    def push_event(self, event, memberid, vid, content):
        body = dict()
        body['vid'] = vid
        body['memberid'] = memberid
        body['event'] = event
        body['content'] = content
        action = dict()
        action['body'] = body
        action['version'] = '1.0'
        action['action_cmd'] = 'push_event'
        action['seq_id'] = '%d' % random.randint(0,10000)
        action['from'] = ''
        if 'push' in self._config:
            self._sendMessage(self._config['push']['Consumer_Queue_Name'], json.dumps(action))

    #///////////////////for Ronaldo only////////////////////////////////
 

