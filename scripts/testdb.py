#!/usr/bin python
# -*- coding: UTF-8 -*-
# filename:  getserviceinfo.py
# creator:   jacob.qian
# datetime:  2013-5-31
# holly 公共模块，发送http信息


import pymongo
import time

def testinsert(begin, end):
    col = pymongo.MongoClient("mongodb://admin:Kr123$^@localhost").test.test
    t1 = time.time()
    for x in xrange(begin,end):
        t3 = time.time()
        insert = dict()
        insert['index'] = x
        insert['value'] = 'a%d' % (x)
        insert['valuelist'] = list()
        col.insert(insert)
        t2 = time.time()
        print '当前插入用时：%f，平均插入1条用时:%f' % ((t2-t3),(t2-t1)/(x*1.0))
    print "总用时%f"% (time.time()-t1)