#!/usr/bin python
# -*- coding: UTF-8 -*-
# filename:  taskmaker_main.py
# creator:   jacob.qian
# datetime:  2013-5-31
# Myth系统广告机发布模块接口
import redis
import sys
import urllib
import urllib2
import httplib2
import cookielib
import xmltodict
from bs4 import BeautifulSoup
import re
import time
import hashlib
import logging.config
logging.config.fileConfig("/opt/Clousky/Tyrant/server/conf/log.conf")
logtyrant = logging.getLogger('tyrant')
import json
if '/opt/Clousky/firearm/apps/ampqapi' not in sys.path:
    sys.path.append('/opt/Clousky/firearm/apps/ampqapi')
import rabbitmq_consume as consumer
import rabbitmq_publish as publisher
if '/opt/Clousky/Tyrant/server/apps/utils' not in sys.path:
    sys.path.append('/opt/Clousky/Tyrant/server/apps/utils')
import sendhttppost
import random

redis = redis.StrictRedis()

def sendActionto(self, routekey, actionname, version, params):
    try:
        if routekey is None or actionname is None or params is None or version is None:
            logtyrant.error("param error")
            return
        logtyrant.debug("key:%s" % (routekey))
        action = dict({'params':params})
        action['name'] = actionname
        action['version'] = version
        action['seqid'] = random.randint(0,9999999999)
        actionlist = list()
        actionlist.append(action)
        body = dict({'actions':{'action':actionlist}})
        bodyxml = xmltodict.unparse(body)
        logtyrant.debug(bodyxml)
        publisher.publish('tyrant', dst_key=routekey, seqid=seqid, msgbody=body)
        self._sendMessage(routekey, bodyxml, uuid.uuid4().__str__())
    except Exception as e:
        logtyrant.error("%s except raised : %s " % (e.__class__, e.args))


def showcookie(cookie):
    logtyrant.debug('========cookie=============')
    for item in cookie:
        logtyrant.debug("%r:%r" % (item.name,item.value))
    logtyrant.debug('===========================')

def getcookie(cookie, name):
    for item in cookie:
        if item.name == name:
            return item.value
    return None

def get_tb_sign(k_cookie, t_time, J_app_key, sign_data):
    sign_string = '%s&%s&%s&%s' % (k_cookie, t_time, J_app_key, sign_data)
    return hashlib.md5(sign_string).hexdigest()

#jsonp2({"api":"com.taobao.client.user.getUserInfo","v":"1.0","ret":["FAIL_SYS_SESSION_EXPIRED::SESSION失效"],"data":{}})
def get_ret(content):
    try:
        retjson = json.loads(content[content.find('(')+1:content.find(')')])
        return retjson['ret'][0].split('::')[0], retjson
    except Exception as e:
        logtyrant.error("%s except raised : %s " % (e.__class__, e.args))
        return None

def _makeclientbodys(action_name, action_version, paramsdict=dict(), invoke_id=None, categroy=None, user_agent=None):
    
    actiondict = dict({'params':paramsdict})
    actionsdict = dict({'action':actiondict})
    xmldict= dict({'actions':actionsdict})
    actiondict['name'] = action_name
    actiondict['version'] = action_version
    actiondict['seqid'] = str(random.randint(1,100000000))

    return xmltodict.unparse(xmldict)

def _getvaluefromactionresponse(request_key, ret, content):
    try:
        if content is not None:
            contentxml = xmltodict.parse(content)
            return contentxml.get('server').get('action').get(request_key)
    except Exception as e:
        logtyrant.error("%s except raised : %s " % (e.__class__, e.args))
        return "UNKOWN"

def _sendhttpaction(module_key, action_name, action_version, action_paramdict):
    bodys = _makeclientbodys(action_name, action_version, action_paramdict)
    obj = sendhttppost.SendHttpPostRequest()
    ret,content = obj.sendhttprequest(module_key,bodys)
    errorcode = _getvaluefromactionresponse('errorcode', ret, content)
    return errorcode, ret, content


def login_tb(cj, username, password):
    logtyrant.debug("=========='http://login.m.taobao.com/login.htm'=================")
    request = urllib2.Request('http://login.m.taobao.com/login.htm')
    request.add_header('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8')
    request.add_header('Accept-Encoding', 'deflate,sdch')
    request.add_header('Accept-Language', 'zh-CN,zh;q=0.8')
    request.add_header('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.57 Safari/537.36')
    request.add_header("Keep-Alive", "115")
    request.add_header("Connection", "keep-alive")
    response = urllib2.urlopen(request)
#    logtyrant.debug(response.read())
#    logtyrant.debug(response.info())
    showcookie(cj)

    rspheader = response.info()
    if 'TBTrack-Id' in rspheader:
        TBTrackId = rspheader['TBTrack-Id']
    else:
        TBTrackId = ''
    content = response.read()
    print content
    soup = BeautifulSoup(content, "html5lib")

    tag = soup.findAll(id = 'J_Exponent')[0]
    if tag.has_attr('value'):
        exponent = tag['value']
    else:
        exponent = 'invalid'
    logtyrant.debug('J_Exponent = %r' % (exponent))
    tag = soup.findAll(id = 'J_Module')[0]
    if tag.has_attr('value'):
        module = tag['value']
    else:
        module = 'invalid'
    logtyrant.debug('J_Module = %r' % (module))
    tag = soup.findAll(id = 'J_Login')[0]
    if tag.has_attr('action'):
        J_Login = tag['action']
    else:
        J_Login = 'invalid'
    logtyrant.debug('J_Login :'+J_Login)

    tag = soup.findAll(attrs={'name':'_tb_token_'})[0]
    if tag.has_attr('value'):
        _tb_token_ = tag['value']
    else:
        _tb_token_ = 'invalid'
    logtyrant.debug('_tb_token_ = %r' % (_tb_token_))
    tag = soup.findAll(attrs={'name':'_umid_token'})[0]
    if tag.has_attr('value'):
        _umid_token = tag['value']
    else:
        _umid_token = 'invalid'
    tag = soup.findAll(attrs={'name':'action'})[0]
    if tag.has_attr('value'):
        action = tag['value']
    else:
        action = 'invalid'
    tag = soup.findAll(attrs={'name':'event_submit_do_login'})[0]
    if tag.has_attr('value'):
        event_submit_do_login = tag['value']
    else:
        event_submit_do_login = 'invalid'
    tag = soup.findAll(attrs={'name':'TPL_redirect_url'})[0]
    logtyrant.debug("TPL_redirect_url:"+"%r" %(tag))
    if tag.has_attr('value'):
        TPL_redirect_url = tag['value']
    else:
        TPL_redirect_url = 'invalid'
    tag = soup.findAll(attrs={'name':'sid'})[0]
    if tag.has_attr('value'):
        sid = tag['value']
    else:
        sid = 'invalid'
    tag = soup.findAll(attrs={'name':'TPL_timestamp'})[0]
    if tag.has_attr('value'):
        TPL_timestamp = tag['value']
    else:
        TPL_timestamp = 'invalid'

    tags = soup.findAll('noscript')
    print tags
    for tag in tags:
        print tag.text
        soup1 = BeautifulSoup(tag.text, "html5lib")
        ts = soup1.findAll('img')
        for t in ts:
            if t['src'].startswith('http://mbuf.alipay.com/'):
                mbufurl = t['src']
                print mbufurl
                break



    #去算密码
    postdata={'password':urllib.quote(password.encode('utf-8')), 'exponent':exponent , 'module':module }
    getpasswordurl = "http://ifans.welaiwang.com:8125/generatersapassword.html"
#    getpasswordurl = "http://211.154.135.169:8125/generatersapassword.html?%s" % (urllib.urlencode(postdata))
#    logtyrant.debug(urllib.urlencode(postdata))
#    logtyrant.debug(getpasswordurl))
    passwordheaders = {
        'Content-Type':'application/x-www-form-urlencoded'
    }
    http = httplib2.Http()
    response, content = http.request(getpasswordurl, "POST", body = urllib.urlencode(postdata), headers = passwordheaders)
    if response['status'] != '200':
        return

    TPL_password2 = content

    #mbuf.alipay.com
    mbufurl +='&jsInfo=1630|855|1630|950|1|22|-|-|-|-|-'
    logtyrant.debug("=================%r ==================" %(mbufurl))  
    request = urllib2.Request(mbufurl)
    request.add_header('Accept', 'image/webp,*/*;q=0.8')
    request.add_header('Accept-Encoding', 'gzip,deflate,sdch')
    request.add_header('Accept-Language', 'zh-CN,zh;q=0.8')
    request.add_header('Cache-Control', 'max-age=0')
    request.add_header('Connection', 'keep-alive')
    request.add_header('Host', 'mbuf.alipay.com')
    request.add_header('Referer', 'http://login.m.taobao.com/login.htm')
    request.add_header('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.57 Safari/537.36')
    response = urllib2.urlopen(request)
#    logtyrant.debug(response.read())
#    logtyrant.debug(response.info())
    showcookie(cj)    

    #log.mmstate.com
    mmstateurl = 'http://log.mmstat.com/m.gif?logtype=1&title=%s&pre=&cache=b03388d&scr=1680x1050&isbeta=0&req_url=http://login.m.taobao.com/login.htm&cna=&category=&pre=&userid=&b2c_orid=&b2c_auction=&at_isb=&atp_isdpp=&at_ssid=&bbid=&aplus&at_cart=&at_alitrackid=&at_udid=&sc=&wp=aXBob25l&sell=&TBTrack_Id=du=%s' % ('手机淘宝网 -  会员登录 ', TBTrackId)

    logtyrant.debug("================%s =========================" % (mmstateurl))
    request = urllib2.Request(mmstateurl)
    request.add_header('Accept', 'image/webp,*/*;q=0.8')
    request.add_header('Accept-Encoding', 'gzip,deflate,sdch')
    request.add_header('Accept-Language', 'zh-CN,zh;q=0.8')
    request.add_header('Cache-Control', 'max-age=0')
    request.add_header('Connection', 'keep-alive')
#    request.add_header('Host', 'log.mmstat.com')
    request.add_header('Referer', 'http://login.m.taobao.com/login.htm')
    request.add_header('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.57 Safari/537.36')
    response = urllib2.urlopen(request)
#    logtyrant.debug(response.read())
#    logtyrant.debug(response.info())
    showcookie(cj)

    logindata = dict()
    logindata['_tb_token_'] = _tb_token_
#    logindata['TPL_username'] = urllib.quote(username.encode('utf-8'))
    logindata['TPL_username'] = username.encode('utf-8')
    logindata['action'] = action
    logindata['event_submit_do_login'] = event_submit_do_login
    logindata['TPL_redirect_url'] = TPL_redirect_url
    logindata['sid'] = sid
    logindata['_umid_token'] = _umid_token
    logindata['TPL_timestamp'] = TPL_timestamp
    logindata['TPL_password2'] = TPL_password2
    request = urllib2.Request(J_Login, data=urllib.urlencode(logindata))
    request.get_method = lambda: 'POST' 
    request.add_header('Accept', 'image/webp,*/*;q=0.8')
    request.add_header('Accept-Encoding', 'gzip,deflate,sdch')
    request.add_header('Accept-Language', 'zh-CN,zh;q=0.8')
    request.add_header('Cache-Control', 'max-age=0')
    request.add_header('Connection', 'keep-alive')
#    request.add_header('Host', 'login.m.taobao.com')
#    request.add_header('Origin', 'http://login.m.taobao.com')
    request.add_header('Content-Type', 'application/x-www-form-urlencoded')
#    request.add_header('Referer', 'http://login.m.taobao.com/login.htm')
    request.add_header('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.57 Safari/537.36')
    response = urllib2.urlopen(request)
#    logtyrant.debug(response.info())
    showcookie(cj)


    #m.taobao.com
    mtaobaourl = "http://m.taobao.com/?sid=%s" % (sid)
    logtyrant.debug("================================================================================================")
    logtyrant.debug("mtaobaourl = %s" % (mtaobaourl))
    request = urllib2.Request(mtaobaourl)
#    request.get_method = lambda: 'POST' 
    request.add_header('Accept', 'image/webp,*/*;q=0.8')
    request.add_header('Accept-Encoding', 'deflate,sdch')
    request.add_header('Accept-Language', 'zh-CN,zh;q=0.8')
    request.add_header('Cache-Control', 'max-age=0')
    request.add_header('Connection', 'keep-alive')
#    request.add_header('Host', 'log.mmstat.com')
#    request.add_header('Origin', 'http://login.m.taobao.com')
#    request.add_header('Content-Type', 'application/x-www-form-urlencoded')
#    request.add_header('Referer', 'http://login.m.taobao.com/login.htm')
    request.add_header('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.57 Safari/537.36')
    response = urllib2.urlopen(request)
#    logtyrant.debug(response.info())
    showcookie(cj)    

    logtyrant.debug("================================================================================================")
    return sid

def getUserInfo(cj, callbackid, J_app_key, sign_data, k_cookie):
    t_time = int(time.time() * 100)
    k_cookie = k_cookie
    sign_data = sign_data
    sign = get_tb_sign(k_cookie, t_time, J_app_key, sign_data)
    
    apimtaobaourl = "http://api.m.taobao.com/rest/h5ApiUpdate.do?callback=jsonp%d&type=jsonp&api=com.taobao.client.user.getUserInfo&v=1.0&data=%s&appKey=%s&sign=%s&t=%s" % (callbackid, sign_data, J_app_key, sign, t_time)
    logtyrant.debug("==========================================h5ApiUpdate======================================================")
    logtyrant.debug("apimtaobaourl = %s" % (apimtaobaourl))
    request = urllib2.Request(apimtaobaourl)
#    request.get_method = lambda: 'POST' 
    request.add_header('Accept', '*/*')
    request.add_header('Accept-Encoding', 'deflate,sdch')
    request.add_header('Accept-Language', 'zh-CN,zh;q=0.8')
    request.add_header('Cache-Control', 'max-age=0')
    request.add_header('Connection', 'keep-alive')
#    request.add_header('Host', 'log.mmstat.com')
#    request.add_header('Origin', 'http://login.m.taobao.com')
#    request.add_header('Content-Type', 'application/x-www-form-urlencoded')
    request.add_header('Referer', 'http://h5.m.taobao.com/my/index.htm')
    request.add_header('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.57 Safari/537.36')
    response = urllib2.urlopen(request)
#    logtyrant.debug(response.info())
    showcookie(cj)
    content = response.read()
    logtyrant.debug(content)
    retcode,retjson = get_ret(content)
    return retcode,retjson
#    if retcode == 'FAIL_SYS_SESSION_EXPIRED':

def followAccount(cj, callbackid, J_app_key, sign_data, k_cookie, accountid, cna, sid):
    account = accountid
#    cna = getcookie(cj,'cna')
    apimtaobaourl = "http://log.m.taobao.com/js.do?callback=jsonp%d&_aplus=1&ap_ref=http://h5.m.taobao.com/we/index.htm?ttid=taobao_h5_1.0.0&sid=%s&spm=41.351606.292993.4&sprefer=pmm731#account/%s/1&ap_cna=%s&ap_uri=http://h5.m.taobao.com/we/index.htm?ttid=taobao_h5_1.0.0&sid=%s&spm=41.351606.292993.4&sprefer=pmm731&log=click_attention#account/%s/1"%(callbackid, sid, account, cna, sid, account)
    Referer = "http://h5.m.taobao.com/we/index.htm?ttid=taobao_h5_1.0.0&sid=%s&spm=41.351606.292993.4&sprefer=pmm731" % (sid)

    logtyrant.debug("==========================================click_attention======================================================")
    logtyrant.debug("apimtaobaourl = %s" % (apimtaobaourl))
    request = urllib2.Request(apimtaobaourl)
#    request.get_method = lambda: 'POST' 
    request.add_header('Accept', '*/*')
    request.add_header('Accept-Encoding', 'deflate,sdch')
    request.add_header('Accept-Language', 'zh-CN,zh;q=0.8')
    request.add_header('Cache-Control', 'max-age=0')
    request.add_header('Connection', 'keep-alive')
#    request.add_header('Host', 'log.mmstat.com')
#    request.add_header('Origin', 'http://login.m.taobao.com')
#    request.add_header('Content-Type', 'application/x-www-form-urlencoded')
    request.add_header('Referer', Referer)
    request.add_header('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.57 Safari/537.36')
    response = urllib2.urlopen(request)
#    logtyrant.debug(response.info())
    showcookie(cj)
    logtyrant.debug(response.read())
    logtyrant.debug("================================================================================================")

    t_time = int(time.time() * 100)
#    k_cookie = getcookie(cj,'_m_h5_tk').split('_')[0]
#    sign_data = '{"snsId":"%s","checkCode":"","sessionId":""}' % (account)
#    sign_string = '%s&%s&%s&%s' % (k_cookie, t_time, J_app_key, sign_data)
#    sign = hashlib.md5(sign_string).hexdigest()
    sign = get_tb_sign(k_cookie, t_time, J_app_key, sign_data)
    apimtaobaourl = 'http://api.m.taobao.com/rest/h5ApiUpdate.do?callback=jsonp%d&type=jsonp&ap_ref=http://h5.m.taobao.com/we/index.htm?ttid=taobao_h5_1.0.0&sid=%s&spm=41.351606.292993.4&sprefer=pmm731#account/%s/1&api=mtop.sns.follow.pubAccount.addWithCheckCode&v=2.0&data={"snsId":"%s","checkCode":"","sessionId":""}&&ttid=taobao_h5_1.0.0&sprefer=pmm731&appKey=%s&sign=%s&t=%s' % (callbackid+1, sid, account, account, J_app_key, sign, t_time)
    Referer = "http://h5.m.taobao.com/we/index.htm?ttid=taobao_h5_1.0.0&sid=%s&spm=41.351606.292993.4&sprefer=pmm731" % (sid)

    logtyrant.debug("=========================================click_attention-2====================================================")
    logtyrant.debug("apimtaobaourl = %s" % (apimtaobaourl))
    request = urllib2.Request(apimtaobaourl)
#    request.get_method = lambda: 'POST' 
    request.add_header('Accept', '*/*')
    request.add_header('Accept-Encoding', 'deflate,sdch')
    request.add_header('Accept-Language', 'zh-CN,zh;q=0.8')
    request.add_header('Cache-Control', 'max-age=0')
    request.add_header('Connection', 'keep-alive')
#    request.add_header('Host', 'log.mmstat.com')
#    request.add_header('Origin', 'http://login.m.taobao.com')
#    request.add_header('Content-Type', 'application/x-www-form-urlencoded')
    request.add_header('Referer', Referer)
    request.add_header('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.57 Safari/537.36')
    response = urllib2.urlopen(request)
#    logtyrant.debug(response.info())
    showcookie(cj)
    content = response.read()
    logtyrant.debug(content)
    retcode,retjson = get_ret(content)
    logtyrant.debug("================================================================================================")
    return retcode,retjson

def login_follow_weitao_by_list(username, password, appkey, member_id, account_list):
    try:
        fileobj = open('/opt/Clousky/Tyrant/server/conf/zombie.conf', 'r')
        zombiecfg = json.load(fileobj)
        fileobj.close()
        sid = ''
        cj = cookielib.LWPCookieJar()
        cookie_support = urllib2.HTTPCookieProcessor(cj)
        httpHandler = urllib2.HTTPHandler(debuglevel=1)
        httpsHandler = urllib2.HTTPSHandler(debuglevel=1)
        opener = urllib2.build_opener(cookie_support, httpHandler, httpsHandler)
        urllib2.install_opener(opener)
        sid = login_tb(cj, username, password)

        #api.m.taobao.com
        time.sleep(float(zombiecfg['session_sleeptime']))
        J_app_key = appkey
    #    t_time = int(time.time() * 100)
        k_cookie = ''
        sign_data = '{}'
    #    sign = get_tb_sign(k_cookie, t_time, J_app_key, sign_data)
        callbackid = 2
        retcode, retjson = getUserInfo(cj, callbackid, J_app_key, sign_data, k_cookie)

        get_tk_failure_times = 0
        while retcode != 'SUCCESS':
            callbackid += 1
            if retcode == 'FAIL_SYS_SESSION_EXPIRED':
                #重做一次登陆
                sid = login_tb(cj, username, password)
                retcode, retjson = getUserInfo(cj, callbackid, J_app_key, sign_data, k_cookie)
            elif retcode == 'FAIL_SYS_TOKEN_EMPTY':
                _m_h5_tk = getcookie(cj,'_m_h5_tk')
                if _m_h5_tk is None:
                    logtyrant.error("no _m_h5_tk in cookie")
                    return
                k_cookie1 = _m_h5_tk.split('_')[0]
                t_time = int(time.time() * 100)
                sign_data1 = '{}'
                cookie = cookielib.Cookie(None, '_s_cookie_', '1', '80', None, 'm.taobao.com', None, None, '/', None, False, t_time+100000,False, None, None, None, False)
                cj.set_cookie(cookie)
                cookie = cookielib.Cookie(None, 'supportWebp', 'false', '80', None, 'm.taobao.com', None, None, '/', None, False, t_time+100000,False, None, None, None, False)
                cj.set_cookie(cookie)
                retcode, retjson = getUserInfo(cj, callbackid, J_app_key, sign_data1, k_cookie1)
            get_tk_failure_times +=1
            if get_tk_failure_times > int(zombiecfg['max_tk_failure_times']):
                return

        cna = getcookie(cj,'cna')
        if cna is None:
            logtyrant.error('cna is None')
            return

        pub = publisher.firearm_publisher(zombiecfg['mq_user'], zombiecfg['mq_password'], zombiecfg['mq_vhost'], zombiecfg['ampq_ip'], int(zombiecfg['ampq_port']))

        for account in account_list:
            #先查询任务是否能做
            action_paramdict = dict()
            action_paramdict['member_id'] = member_id
            action_paramdict['task_id'] = account['task_id']
            action_paramdict['provider_nickname'] = urllib.quote(username.encode('utf-8'))
            errorcode, ret, content = _sendhttpaction('tyrant-tasktree', 'task_check_do', '1.0', action_paramdict)
            if errorcode != '200':
                continue
            _m_h5_tk = getcookie(cj,'_m_h5_tk')
            if _m_h5_tk is None:
                logtyrant.error("no _m_h5_tk in cookie")
                return
            k_cookie = _m_h5_tk.split('_')[0]
    #        k_cookie = getcookie(cj,'_m_h5_tk').split('_')[0]
            sign_data = '{"snsId":"%s","checkCode":"","sessionId":""}' % (account['task_account_id'])
            retcode, retjson = followAccount(cj, callbackid, J_app_key, sign_data, k_cookie, account['task_account_id'], cna, sid)
            if retcode == 'SUCCESS' and retjson['data']['isSuccess'] == 'true':
                params = dict()
                params['member_id'] = member_id
                params['task_id'] = account['task_id']
                params['user_agent'] = 'PC'
                params['provider_nickname'] = urllib.quote(username.encode('utf-8'))
                action = dict({'params':params})
                action['name'] = 'task_execute'
                action['version'] = '1.0'
                action['seqid'] = random.randint(0,9999999999)
                actionlist = list()
                actionlist.append(action)
                body = dict({'actions':{'action':actionlist}})
                bodyxml = xmltodict.unparse(body)
                logtyrant.debug(bodyxml)
                pub.publish(userid = zombiecfg['mq_user'], dst_key = 'tyrant-task', seqid='%s' % (random.randint(0,9999999999)), msgbody=bodyxml)            
            time.sleep(float(zombiecfg['follow_task_timesleep']))
        return
    except Exception as e:
        logtyrant.error("%s except raised : %s " % (e.__class__, e.args))
        return

    


if __name__ == "__main__":
    ''' parm1: moduleid,
    '''
#login_follow_weitao_by_list(username, password, appkey, member_id, account_list):
    username = 'gabrielliao'
    password = 'fossil19780608'
#    username = 'general2k'
#    password = 'qianfeng1234'
#    login_follow_weitao_by_list(u'Tao女郎妮妮', u'HANrui0380', '12574478', '6c362b2a-2754-4291-9ef9-a909c773718f', [{'task_account_id':'2086815204', 'task_id':'274bac57-47d5-4cc5-84f1-90300fb2f197'}])

    
    agentlist = redis.keys('tyrant:term:ip:*')
    print agentlist
    proxyip = ''
    if len(agentlist):
    	cj = cookielib.LWPCookieJar()
        cookie_support = urllib2.HTTPCookieProcessor(cj)
        httpHandler = urllib2.HTTPHandler(debuglevel=1)
        httpsHandler = urllib2.HTTPSHandler(debuglevel=1)

        proxyip = redis.hget(agentlist[0],'ip')
        print proxyip
        proxy_handler = urllib2.ProxyHandler({'http': proxyip})
        opener = urllib2.build_opener(cookie_support, httpHandler, httpsHandler, proxy_handler)
        urllib2.install_opener(opener)
        sid = login_tb(cj, username, password)

