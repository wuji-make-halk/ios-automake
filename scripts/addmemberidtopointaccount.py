#!/usr/bin python
# -*- coding: UTF-8 -*-
# filename:  getserviceinfo.py
# creator:   jacob.qian
# datetime:  2013-5-31
# holly 公共模块，发送http信息

# import urllib
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


def commitData2(queue):
    print("into commitData2")
    fileobj = open('/opt/Clousky/Ronaldo/server/conf/db.conf', 'r')
    json_dbcfg = json.load(fileobj)
    fileobj.close()

    conn = mysql.connect(host=json_dbcfg['host'], user=json_dbcfg['user'], passwd=json_dbcfg[
                         'passwd'], db=json_dbcfg['dbname'], charset=json_dbcfg['charset'])
    cursor = conn.cursor(cursorclass=mysql.cursors.DictCursor)

    insertCnt = 0
    sleepCnt = 0
    while True:
        try:
            if queue.empty():
                if insertCnt > 0:
                    insertCnt = 0
                    conn.commit()
                else:
                    if sleepCnt >= 6000:
                        sleepCnt = 0
                        conn.ping()
                        print(
                            "commitData2 do mysql ping action to avoid lost connection ...")
                    else:
                        time.sleep(0.1)
                        sleepCnt = sleepCnt + 1
            else:
                sleepCnt = 0
                buf = queue.get()
                insertResult = cursor.execute(buf)
                print("execute insert sql script [%s]" % (buf))
                if insertCnt % 10000 == 0:
                    insertCnt = 0
                    conn.commit()

                insertCnt = insertCnt + 1
        except mysql.Error, e:
            print("commit Error %d: %s" % (
                e.args[0], e.args[1]))
        except:
            print("commit Error")

    conn.close()

    thread.exit_thread()

def ex(cursor, sqlstr):
    print 'execut [%r]'%(sqlstr)
    return cursor.execute(sqlstr)


def importtrade(queue, sorderid = None):
#    try:
    fileobj = open('/opt/Clousky/Ronaldo/server/conf/db.conf', 'r')
    json_dbcfg = json.load(fileobj)
    fileobj.close()

    conn = mysql.connect(host=json_dbcfg['host'], user=json_dbcfg['user'], passwd=json_dbcfg[
                         'passwd'], db=json_dbcfg['dbname'], charset=json_dbcfg['charset'])
    cursor = conn.cursor(cursorclass=mysql.cursors.DictCursor)
    count = cursor.execute("SELECT * from tbl_Ronaldo_member_account_point")
    rows = cursor.fetchall()
    for row in rows:
        count = cursor.execute("SELECT * from tbl_Ronaldo_member_account_bind where account_uuid = '%s'" % (row['account_uuid']))
        if count:
            r = cursor.fetchone()
            if r['member_uuid'] is None:
                member_uuid = ''
            else:
                member_uuid = r['member_uuid']
        else:
            member_uuid = ''

        sqlstr = "UPDATE tbl_Ronaldo_member_account_point set member_uuid = '%s' where account_uuid = '%s'" % (member_uuid, row['account_uuid'])
        queue.put(sqlstr)
    cursor.close()
    conn.close()
    return
#    except Exception as e:
#        print ("%s except raised : %s " % (e.__class__, e.args))
#        return 0


if __name__ == "__main__":
    ''' parm1: moduleid,
    '''
    _squeue = Queue.Queue()
    thread.start_new_thread(commitData2, (_squeue,))

    importtrade(_squeue)
    while 1:
    	time.sleep(1)
