#!/usr/bin python
# -*- coding: UTF-8 -*-
# filename:  gearcenter_worker.py
# creator:   jacob.qian
# datetime:  2013-5-31
# Ronaldo gearcenter 工作线程

import sys
import subprocess
import os
import time
import datetime
import time
import threading
import random
import shutil
# if '..' not in sys.path:
#     sys.path.append('..')
# from apps.common import workers
sys.path.append(os.getcwd()+'/apps/common')
import workers
from imageManager import ImageManager

import json
import pymongo
import redis
import urllib
import urllib2
import logging
import logging.config
import uuid
import codecs
from bson.objectid import ObjectId
import plistlib

projectpath = os.getcwd()
tempFilePath = projectpath+'/tempfile/'
logging.config.fileConfig(projectpath+"/conf/log.conf")
logr = logging.getLogger('ronaldo')


class AutoMake(threading.Thread, workers.WorkerBase):

    def __init__(self, moduleid):
        logr.debug("IosAutoMake :running in __init__")
        threading.Thread.__init__(self)
        workers.WorkerBase.__init__(self, moduleid)
#        self.mongoconn = pymongo.Connection(self._json_dbcfg['mongo_ip'],int(self._json_dbcfg['mongo_port']))
        # self.mongoconn = pymongo.MongoClient('mongodb://%s:%s@%s:%s/' % (self._json_dbcfg['user'],self._json_dbcfg['passwd'],self._json_dbcfg['host'],self._json_dbcfg['port']))
        self._redis = redis.StrictRedis(self._json_dbcfg['redisip'], int(self._json_dbcfg['redisport']),password=self._json_dbcfg['redispassword'])
        self._callbackMessageQueueName = ''
        # self.db = self.mongoconn.gearcenter
        # self.collection = self.db.gear_authinfo
        # self.gearlog = self.db.gear_authlog
        # self.collection_wxgearinfo = self.db.wxdeviceinfo
        # self.collection_progresses = self.db.progresses

#        self.memberconn = pymongo.Connection(self._json_dbcfg['mongo_ip'],int(self._json_dbcfg['mongo_port']))
        # self.memberconn = pymongo.MongoClient('mongodb://%s:%s@%s:%s/' % (self._json_dbcfg['user'],self._json_dbcfg['passwd'],self._json_dbcfg['host'],self._json_dbcfg['port']))
        # self.memberdb = self.memberconn.member
        # self.collect_memberinfo = self.memberdb.memberinfo
        # self.collect_member_device_log = self.memberdb.devicelog
        self.thread_index = moduleid
        self.actionstep = 0
        self.recv_queue_name = "W:Queue:IosAutoMake"
        if 'automake' in self._config:
            if 'Consumer_Queue_Name' in self._config['automake']:
                self.recv_queue_name = self._config['automake']['Consumer_Queue_Name']
            if 'Callback_MessageQueueName' in self._config['automake']:
                self._callbackMessageQueueName = self._config['automake']['Callback_MessageQueueName']

    def __str__(self):
        pass
        '''

        '''

    def _proc_message(self, recvbuf):
        '''消息处理入口函数'''
        # logr.debug('_proc_message')
        #解body
        msgdict = dict()
        try:
            logr.debug(recvbuf)
            msgdict = json.loads(recvbuf)
        except:
            logr.error("parse body error")
            return
        #检查消息必选项
        if len(msgdict) == 0:
            logr.error("body lenght is zero")
            return
        # msgfrom = ""
        # if "from" in msgdict:
        #     logr.error("no route in body")
        #     msgfrom = msgdict['from']

        seqid = '0'
        if "seqid" in msgdict:
            seqid = msgdict['seqid']

        version = '1.0'
        if "version" in msgdict:
            version = msgdict['version']

        # sockid = ''
        # if 'sockid' in msgdict:
        #     sockid = msgdict['sockid']

        if "action_cmd" not in msgdict:
            logr.error("no action_cmd in msg")
            self._sendMessage(self._callbackMessageQueueName, '{"from":%s,"error_code":"40000","seq_id":%s,"body":{})' % ('', seqid))
            return
        #构建回应消息结构
        action_cmd = msgdict['action_cmd']

        message_resp_dict = dict()
        message_resp_dict['from'] = ''
        message_resp_dict['seq_id'] = seqid
        message_resp_dict['version'] = version
        # message_resp_dict['sockid'] = sockid
        message_resp_body = dict()
        message_resp_dict['body'] = message_resp_body

        self._proc_action(msgdict, message_resp_dict, message_resp_body)

        msg_resp = json.dumps(message_resp_dict)
        logr.debug(msg_resp)
        self._sendMessage(self._callbackMessageQueueName, msg_resp)   

    def _proc_action(self, msg_in, msg_out_head, msg_out_body):
        '''action处理入口函数'''
        if 'action_cmd' not in msg_in or 'version' not in msg_in:
            logr.error("mandotry param error in action")
            msg_out_head['error_code'] = '40002'
            return
        action_cmd = msg_in['action_cmd']
#        logr.debug('action_cmd : %s' % (action_cmd))
        action_version = msg_in['version']
#        logr.debug('action_version : %s' % (action_version))
        if 'body' in msg_in:
            action_body = msg_in['body']
#            logr.debug('action_body : %s' % (action_body))
        else:
            action_body = None
            logr.debug('no action_body')

        if action_cmd == 'create_iapplication':
            self._proc_action_create_iapplication(action_version, action_body, msg_out_head, msg_out_body)
        else:
            msg_out_head['error_code'] = self.ERRORCODE_UNKOWN_CMD

        return


    def start_forever(self):
        logr.debug("running in start_forever")
        self._start_consumer()

    def run(self):
        logr.debug("Start AutoMake pid=%s, threadindex = %s" % (os.getpid(),self.thread_index))
#        try:
        if 1:
            while 1:
                recvdata = self._redis.brpop(self.recv_queue_name)
                t1 = time.time()
                if recvdata:
                    self._proc_message(recvdata[1])
                logr.debug("_proc_message cost %f" % (time.time()-t1))            

    def _proc_action_create_iapplication(self, version, action_body, retdict, retbody):
        '''
        input : {    'action_cmd'  : 'gear_add', M
                     'seq_id      : M
                     'version'    : M
                     'body'   :{
                        'vid'    : M
                        'gear_type'     : M
                        'mac_id_start'     : M
                        'mac_id_end'   : O
                        'count'    : M
                    }
                }

        output:{   
                   'error_code       : "200"'
                   'seq_id'         : M
                }
        '''
        logr.debug(" into _proc_action_create_iapplication action_body:%s"%action_body)
        try:

            # retdict['action_cmd'] = 'create_iapplication_callback'
            # retbody.update(action_body)
            # if 'path' in retbody:
            #     retbody.pop('path')
            # #先获取json格式配置文件
            # path = action_body.get('path')
            # if path is None or path == '':
            #     retbody['result'] = self.ERRORCODE_CMD_HAS_INVALID_PARAM
            #     return

            # configdict = json.loads(urllib.urlopen(path).read())
            # logr.debug(configdict)
            if 'appid' not in action_body or 'secret' not in action_body or 'vid' not in action_body or 'template' not in action_body or 'bundle_id' not in action_body:
                self.send_callback(bundle_id,vid,'40001','miss mandotry parameters', pgyerurl)
                return
            appid = action_body['appid']
            secret = action_body['secret']
            vid = action_body['vid']
            templatename = action_body['template']
            bundle_id = action_body['bundle_id']
            custom_list = action_body.get('custom_list')
            pgyerurl = ''

            os.chdir(projectpath)

            self.actionstep = 1
            #第一步，查找template目录中是否存在template
            self.showlog("debug","find template [%s]" % (templatename))
            # logr.debug("action %d: find template [%s]" % (i,templatename))
            templatepath = projectpath+'/template/%s' % (templatename)
            if os.path.exists(templatepath) is False:
                self.showlog('error',"template error: [%s] not exists" % (templatename))
                # logr.error("template error: [%s] not exists" % (templatename))
                self.send_callback(bundle_id,vid,'40002','template [%s] not exists' % (templatename), pgyerurl)
                return
            # i+=1
            #第二步，模板代码git 更新 失败不用返回
            os.chdir(templatepath)
            logr.debug("action %d: template [%s] git pull automake branch " % (i,templatename))
            output = subprocess.check_output(['git', 'pull','origin','automake'])
            logr.debug(output)

            logr.debug("action %d: template [%s] git checkout  automake branch " % (i,templatename))
            output = subprocess.check_output(['git', 'checkout','automake'])
            logr.debug(output)

            # if self.checkoutput(output,'finished successfully') is False:
            #     self.showlog('error',"git error: [%s] git pull error" %(templatename))
            #     # return
            # # i+=1

            os.chdir(projectpath)

            #第三步，将代码拷贝到target目录
            targetpath = projectpath + '/target/%s' % (bundle_id)
            self.showlog('debug',"copy template from [%s] to [%s] " % (templatepath+'/',targetpath))
            # if os.path.exists(targetpath) is False:
            #     os.mkdir(targetpath)

            output = subprocess.check_output(['cp','-rf',templatepath+'/',targetpath])
            # i+=1
            #第四步 删除.git信息
            self.showlog('debug',"rm target [%s] 's .git directory " % (targetpath))            
            output = subprocess.check_output(['rm','-rf',('%s/.git' % (targetpath))])

            # i+=1
            #获取模板配置文件
            templateconfigpath = projectpath + '/template/config.conf'
            if os.path.exists(templateconfigpath) is False:
                self.send_callback(bundle_id,vid,'40002','miss [%s]'%(templateconfigpath), pgyerurl)
                return
            fb = open(templateconfigpath,'r')
            readfiles = json.load(fb)
            fb.close()
            templateconfig = readfiles.get(templatename)
            self.showlog('debug',"read templateconfig %s " % (templateconfig))
            # i+=1
            if templateconfig is None:
                self.send_callback(bundle_id,vid,'40003','templateconfig is None', pgyerurl)
                return

            configPlistPath = targetpath +'/'+ templateconfig.get('configfilepath')
            imageFilePath = targetpath +'/'+ templateconfig.get('imagefilepath')
            logosplashPath = targetpath +'/'+ templateconfig.get('imagexcassetspath')
            fastlanePath = targetpath +'/'+ templateconfig.get('fastlanepath')
            localizablePath = targetpath +'/'+ templateconfig.get('localizablepath')
            #第五步 更新VID信息 找到config.plist文件
            configplist = plistlib.readPlist(configPlistPath+'config.plist')
            self.showlog('debug',"read config.plist is %s " % (configplist))
            # i+=1
            configplist['vid'] = vid
            self.showlog('debug',"modify [config.plist].[vid] ->[%s] " % (vid))
            # i+=1

            #更改fastlane里面的bundleid
            fastlanefile = fastlanePath+'Fastfile'
            if os.path.exists(fastlanefile) is False:
                self.send_callback(bundle_id,vid,'40004','miss [%s]'%(fastlanefile), pgyerurl)
                return
            fb = codecs.open(fastlanefile,'r',"utf-8")
            fastlanecontentlist = fb.readlines()
            fb.close()
            for n,line in enumerate(fastlanecontentlist):
                if line.find('custom_app_identifier = ') > 0:
                    fastlanecontentlist[n] = '    custom_app_identifier = "com.general2k.%s"\n' % (bundle_id)
                    self.showlog('debug',"modify [fastlinefile].[%s] " % (fastlanecontentlist[n]))
                    # i+=1
                # if line.find('custom_app_name = ')>0:
                #     fastlanecontentlist[n]  = '    custom_app_name = "%s"\n' % (bundle_id)
                #     logr.debug("action %d: modify [fastlinefile].[%s] " % (i,fastlanecontentlist[n]))
                #     i+=1
            #处理信息定制
            for custominfo in custom_list:
                if custominfo['target_type'] == 'fastlane':
                    findkey = custominfo['target'] + ' ='
                    for n,line in enumerate(fastlanecontentlist):
                        if line.find(findkey)>0:
                            fastlanecontentlist[n]  = '    %s = "%s"\n' % (custominfo['target'],custominfo['value'])
                            self.showlog('debug',"modify [fastlinefile].[%s] " % (fastlanecontentlist[n]))
                            # i+=1
                elif custominfo['target_type'] == 'logosplash':
                    #下载图片文件 target_type = logosplash, target语法是
                    downloadurl = custominfo['value']
                    saveImagePath = self.downloadImage(downloadurl)
                    imgManager = ImageManager(saveImagePath)
                    targetPath = logosplashPath+custominfo['target']
                    logoconfigFilePath = targetPath+'/Contents.json'
                    if os.path.exists(logoconfigFilePath) is False:
                        self.showlog('error',"can't find [%s] " % (logoconfigFilePath))
                        # i+=1
                        continue
                    fb = open(logoconfigFilePath,'r')
                    logo_json = json.load(fb)
                    fb.close()
                    imagelist = logo_json.get('images')
                    for imageinfo in imagelist:
                        if "filename" not in imageinfo:
                            continue
                        idiom = imageinfo['idiom']
                        if idiom != 'iphone':
                            continue
                        filename = imageinfo['filename']
                        savepath = targetPath+'/'+filename
                        #有extent代表是splash，否则是logo
                        extent = imageinfo.get('extent')
                        if extent is None:
                            sizestr = imageinfo['size']
                            scale = int(imageinfo['scale'][0])
                            size = int(sizestr.split('x')[0])*scale
                            # savepath = targetPath+'/'+filename
                            imgManager.convertImageToSize(size,size,savepath)
                            self.showlog("debug","save AppIcon(%dx%d) to [%s]" % (size,size,savepath))
                        else:
                            subtype = imageinfo.get('subtype')
                            scale = int(imageinfo['scale'][0])
                            orientation = imageinfo.get('orientation')
                            # savepath = targetPath+'/'+filename
                            if orientation is None or orientation == 'landscape':
                                #不处理横屏模式
                                continue
                            sizex = 320
                            sizey = 480
                            if subtype is None:
                                #没有subtype就代表是320*480模式
                                sizex = sizex*scale
                                sizey = sizey*scale
                            elif subtype == 'retina4':
                                sizex = 640
                                sizey = 1136
                            elif subtype == '736h':
                                sizex = 1242
                                sizey = 2208
                            elif subtype == '667h':
                                sizex = 750
                                sizey = 1334
                            imgManager.convertImageToSize(sizex,sizey,savepath)
                            self.showlog("debug","save LaunchImage(%dx%d) to [%s]" % (sizex,sizey,savepath))
                    imgManager.close()
                elif custominfo['target_type'] == 'image':
                    downloadurl = custominfo['value']
                    saveImagePath = self.downloadImage(downloadurl)
                    imgManager = ImageManager(saveImagePath)
                    savepath = imageFilePath+custominfo['target']
                    imgManager.convertImageToPNG(savepath)
                    self.showlog("debug","save custom image file to [%s]" % (savepath))
                elif custominfo['target_type'] == 'configfile':
                    value = custominfo['value']
                    target = custominfo['target']
                    self.replaceValueByKey(i,configplist,target,value)
                elif custominfo['target_type'] == 'infopliststring':
                    #替换内容
                    value = custominfo['value']
                    targetlist = custominfo['target'].split(":")
                    languageInd = targetlist[0]
                    replaceKey = targetlist[1]
                    # logr.debug(targetlist)
                    #先判断是否有本地化，看infoPlist.Strings是否存在
                    pliststringPath = localizablePath+'InfoPlist.strings'
                    isFind = False
                    if os.path.exists(pliststringPath) is False:
                        projlist = os.listdir(localizablePath)
                        for projdirname in projlist:
                            if projdirname.endswith('lproj') is False:
                                continue
                            if projdirname.startswith(languageInd) is True:
                                pliststringPath = localizablePath+projdirname+'/InfoPlist.strings'
                                isFind = True
                                break
                    else:
                        if os.path.isdir(pliststringPath) is False:
                            isFind = True

                    if isFind is True:
                        fb1 = codecs.open(pliststringPath,'r','utf-8')
                        contentlist = fb1.readlines()
                        # logr.debug(contentlist)
                        fb1.close()
                        
                        for n,line in enumerate(contentlist):
                            if line.find(replaceKey)>=0:
                                contentlist[n] = '%s = "%s";\n' % (replaceKey,value)
                                self.showlog('debug',"modify [%s].[%s] " % (pliststringPath,contentlist[n]))
                                break
                        # logr.debug(contentlist)
                        fb2 = codecs.open(pliststringPath,'w+',"utf-8")
                        fb2.write(''.join(contentlist))
                        fb2.close()
                        self.showlog("debug","save pliststrings file to [%s]" % (pliststringPath))
            #生成fastfile
            fb = codecs.open(fastlanefile,'w+',"utf-8")
            fb.write(''.join(fastlanecontentlist))
            fb.close()
            self.showlog("debug","save fastlane file to [%s]" % (fastlanefile))
            #生成config.plist
            plistlib.writePlist(configplist,configPlistPath+'config.plist')
            self.showlog("debug","save configfile file to [%s]" % (configPlistPath+'config.plist'))

            self.showlog("debug","Run Fastlane ----->")
            os.chdir(targetpath)
            output = subprocess.check_output(['fastlane','release'])
            for line in output.splitlines():
                if line.find('Upload success. Visit this URL to see: ') > 0:
                    pgyerurl = line.split('Upload success. Visit this URL to see: ')[1][0:26]
                    self.showlog("debug","upload to Pgyer url is [%s]" % (pgyerurl))
                    break
            os.chdir(projectpath)

            self.send_callback(bundle_id,vid,'200','OK', pgyerurl)



        except Exception as e:
            if output is not None:
                for l in output.splitlines():
                    logr.error(l)
            logr.error("%s except raised : %s " % (e.__class__, e.args))
            self.send_callback(bundle_id,vid,'40000','Exception:%s' % (e.args), pgyerurl)
            return

    def replaceValueByKey(self,i,plistdict,key,value):
        keylist = key.split(':')
        subkey = keylist.pop(-1)
        searchdict = plistdict
        pathkey = ''
        for key in keylist:
            if pathkey == '':
                pathkey = key
            else:
                pathkey = pathkey + '->' +key

            if key not in searchdict:
                self.showlog("error","can't find [%s] in config.plist" % (pathkey))
                return
            searchdict = searchdict[key]
        if subkey not in searchdict:
            self.showlog("error","can't find [%s->%s] in config.plist" % (pathkey,subkey))
            return
        else:
            searchdict[subkey] = value
            self.showlog("debug","custom config.plist [%s] -> [%s]" % (key,value))




    def showlog(self,level,content):
        showcontent = ">>[action %d]<< : %s" %(self.actionstep, content)
        if level == 'debug':
            logr.debug(showcontent)
        else:
            logr.error(showcontent)
        self.actionstep+=1


    def checkoutput(self,output,successflag):
        for line in output.splitlines():
            if line.find(successflag) > 0:
                return True

        return False

    def downloadFile(self,fromurl,dest):
        url = ''
        if fromurl.startswith('/') is True:
            url = 'http://dev.keeprapid.com'+fromurl
        else:
            url = 'http://dev.keeprapid.com/'+fromurl
        urllib.urlretrieve(url,dest)


    def downloadImage(self,fromurl):
        url = ''
        if fromurl.startswith('/') is True:
            url = 'http://dev.keeprapid.com'+fromurl
        else:
            url = 'http://dev.keeprapid.com/'+fromurl
        filename = fromurl.split('/')[-1]
        savePath = tempFilePath+filename
        urllib.urlretrieve(url,savePath)
        return savePath

    def send_callback(self,name,vid,errorcode,info,url):
        content = dict()
        content['name'] = name
        content['vid'] = vid
        content['code'] = errorcode
        content['info'] = info
        content['url'] = url
        logr.debug("send callback %r"%(content))
        url = "http://dev.keeprapid.com/template/ios_created"
        req = urllib2.Request(url,urllib.urlencode(content))
        urllib2.urlopen(req)

if __name__ == "__main__":
    ''' parm1: moduleid,
    '''
    fileobj = open("./conf/config.conf", "r")
    _config = json.load(fileobj)
    fileobj.close()

    thread_count = 1
    if _config is not None and 'automake' in _config and _config['automake'] is not None:
        if 'thread_count' in _config['automake'] and _config['automake']['thread_count'] is not None:
            thread_count = int(_config['automake']['thread_count'])

    for i in xrange(0, thread_count):
        memberlogic = AutoMake(i)
        memberlogic.setDaemon(True)
        memberlogic.start()

    while 1:
        time.sleep(1)
