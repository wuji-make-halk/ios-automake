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
import hmac
import uuid
from bson.objectid import ObjectId
import httplib

if __name__ == "__main__":
    ''' parm1: moduleid,
    '''

    conn = pymongo.MongoClient("mongodb://admin:Kr123$^@localhost:27017")
    db = conn.member
    col_member = db.memberinfo
    conn1 = pymongo.MongoClient("mongodb://admin:Kr123$^@localhost:27017")
    db1 = conn1.datacenter
    col_summary = db1.summary
    col_board = db1.board


    AccessKeyId = "LTAI4Fh1GoZDNac6ZHUrRUqV"
    AccessKeySecret = "Eoojm0WYF8y1KvTNT47XyAaGQfgBnv"

    datestr = time.strftime('%Y-%m-%d',time.localtime(time.time()-12*60*60))
    boarditer = col_summary.find({'datestr':datestr}).limit(100).sort('sum_step',pymongo.DESCENDING)

    memberlistinfo = list()
    memberlistinfo.append(u"<table border=\"1\"><tr><th>用户名</th><th>名称</th><th>步数</th><th>用户id</th><th>联系方式</th></tr>")

    board_memberlist = list()
    updatedict = dict()
    updatedict['memberlist'] = board_memberlist
    querydict = dict()

    querydict['datestr'] = datestr
    querydict['vid'] = '000004001004'
    querydict['data_type'] = 'fitness'
    querydict['compareval'] = 'sum_step'

    i = 0
    for summaryinfo in boarditer:
        if 'username' not in summaryinfo or 'sum_step' not in summaryinfo:
            continue
        i+=1
        memberinfo = col_member.find_one({'_id':ObjectId(summaryinfo['memberid'])})
        contact = ''
        if memberinfo is not None:
            contact = memberinfo.get('contact')
        name = ''
        if memberinfo is not None:
            name = memberinfo.get('name')
            if name == '':
                name = memberinfo.get('username')
        headimg = ''
        if memberinfo is not None and 'headimg' in memberinfo:
            headimg = memberinfo.get('headimg')
        headimg_fmt = ''
        if memberinfo is not None and 'headimg_fmt' in memberinfo:
            headimg_fmt = memberinfo.get('headimg_fmt')

        board_memberinfo = dict()
        board_memberinfo['username'] = summaryinfo['username']
        board_memberinfo['sum_step'] = summaryinfo['sum_step']
        board_memberinfo['memberid'] = summaryinfo['memberid']
        board_memberinfo['name'] = name
        board_memberinfo['headimg'] = headimg
        board_memberinfo['headimg_fmt'] = headimg_fmt
        board_memberinfo['membertype'] = memberinfo.get('membertype')
        board_memberinfo['memberlevel'] = memberinfo.get('memberlevel')
        board_memberinfo['followtype'] = memberinfo.get('followtype')
        board_memberinfo['introduce'] = memberinfo.get('introduce')
        board_memberlist.append(board_memberinfo)
        if i<=30:
            memberboardinfo = u"<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td>" % (summaryinfo['username'],name,summaryinfo['sum_step'],summaryinfo['memberid'],contact)
            memberlistinfo.append(memberboardinfo)

    updatedict['count'] = i
    updatedict['lastupdatetimestamp'] = time.time()
    col_board.update_one(querydict,{'$set':updatedict},upsert = True)

    memberlistinfo.append(u"</table>")
    deadline = time.strftime('%H:%M:%S',time.localtime(time.time()))
    email_contact = u"<html><body><b>%s 日排行榜如下(截止时间:%s）:</b></p>%s</body></html>" % (datestr,deadline,''.join(memberlistinfo))
#    print email_contact

    url = "http://dm.aliyuncs.com"
    postdict = dict()
    postdict['Format'] = 'JSON'
    postdict['Version'] = '2015-11-23'
    postdict['SignatureMethod'] = 'HMAC-SHA1'
    postdict['AccessKeyId'] = AccessKeyId
    postdict['SignatureVersion'] = '1.0'
    postdict['SignatureNonce'] = uuid.uuid4().__str__()
    postdict['Timestamp'] = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
    postdict['Action'] = 'SingleSendMail'
    postdict['AccountName'] = 'noreply@mail1.keeprapid.com'
    postdict['ReplyToAddress'] = True
    postdict['AddressType'] = 1
    postdict['ToAddress'] = '10614126@qq.com,838333180@qq.com,hzf218@126.com,625026901@qq.com'.encode('utf-8')
#    postdict['ToAddress'] = '10614126@qq.com'.encode('utf-8')
    postdict['Subject'] = (u'%s奖金榜' % (datestr)).encode('utf-8')
    postdict['HtmlBody'] = email_contact.encode('utf-8')
    #u'<html><body><b>2016-08-09 日排行榜如下(截止时间:00:18:46）:</b></p><table border="1"><tr><th>用户名</th><th>名称</th><th>步数</th><th>用户id</th><th>联系方式</th></tr><tr><td>519076232@qq.com</td><td>华子</td><td>16029</td><td>570b263f4d2a2e704640ba09</td><td></td><tr><td>393828419@qq.com</td><td>发</td><td>7623</td><td>573039d24d2a2e7f77f3d81a</td><td>好</td><tr><td>450548909@qq.com</td><td>何勇</td><td>7233</td><td>57495dcc4d2a2e2b43fd9e30</td><td></td><tr><td>107928321@qq.com</td><td>涛</td><td>6974</td><td>5626f39b4d2a2e0ab1288382</td><td>11011011058</td><tr><td>315066888@qq.com</td><td>panda</td><td>6556</td><td>5706e1874d2a2e7045fa2b5c</td><td></td><tr><td>hzf218@126.com</td><td>黄治发</td><td>6409</td><td>550f6d034d2a2e5fcb82b03a</td><td>13715358218</td><tr><td>412667317@qq.com</td><td>Jocelyn</td><td>5939</td><td>546b7ec94d2a2e4fbfcedb7d</td><td>QQ:412667317</td><tr><td>714951178@qq.com</td><td>肖旭红</td><td>5273</td><td>56ecb0a94d2a2e095fc15eef</td><td></td><tr><td>1197239193@qq.com</td><td>郭纳</td><td>4973</td><td>574962604d2a2e2b45a5ddec</td><td></td><tr><td>386391670@qq.com</td><td>快乐生活~波</td><td>1325</td><td>574b90044d2a2e09796e16dc</td><td></td><tr><td>675872637@qq.com</td><td></td><td>1026</td><td>5774a1a04d2a2e0f8f7459ce</td><td></td><tr><td>1292412899@qq.com</td><td></td><td>261</td><td>56f5e7494d2a2e03f6998219</td><td></td><tr><td>3049163802@qq.com</td><td></td><td>106</td><td>579fe6b24d2a2e49205ff861</td><td></td><tr><td>546905845@qq.com</td><td></td><td>106</td><td>573421d54d2a2e7056695a61</td><td></td></table></body></html>'.encode('utf-8')
    #email_contact.encode('utf-8')

    a = postdict.keys()
    a.sort()
    signstr = ""
    for key in a:
        if signstr == '':
            signstr = "%s=%s" % (key,postdict[key])
        else:
            if key in ['Timestamp','AccountName','ToAddress','HtmlBody','Subject']:
                signstr = "%s&%s=%s" % (signstr,key,urllib.quote(postdict[key]).replace('/', '%2F').replace('%7E','~').replace('+','%20').replace('*','%2A'))
            else:
                signstr = "%s&%s=%s" % (signstr,key,postdict[key])

#    print signstr
#    print '---->'
    signstr = 'POST&%2F&'+urllib.quote(signstr).replace('%7E','~').replace('+','%20').replace('*','%2A')
#    print(signstr)
    token = "%s&"%(AccessKeySecret)
    sign = hmac.new(token,signstr,hashlib.sha1).digest().encode('base64').rstrip()

    postdict['Signature'] = sign

    headers = {"Content-type": "application/x-www-form-urlencoded"}
    data = urllib.urlencode(postdict)
#    print(data)
    httpClient = httplib.HTTPConnection('dm.aliyuncs.com')
    httpClient.request("POST", "/", data, headers)
    response = httpClient.getresponse()
#    print(response.status)
#    print(response.read())
