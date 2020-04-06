#!/usr/bin/python
# -*- coding: UTF-8 -*-
# SMGP v3.0 api file
import redis

r = redis.StrictRedis(password='Kr123456')

tids = r.keys('R:token:*')
existmemberidlist = set()
needdelmemberidlist = set()
allmemberidlist = set()
for tid in tids:
    memberid = r.hget(tid,'memberid')
    if memberid is not None:
        existmemberidlist.add(memberid)

memberinfos = r.keys('R:minfo*')
totalmembers = len(memberinfos)
needdelmembers = 0

for memberinfo in memberinfos:
    memberid = memberinfo.split(':')[2]
    allmemberidlist.add(memberid)


    # if memberid not in existmemberidlist:
    #     needdelmembers += 1
    #     if needdelmembers%1000 == 0:
    #         print needdelmembers
    #     # print 'need del[%s]' % (memberinfo)
needdelmemberidlist = allmemberidlist.difference(existmemberidlist)

print 'total = %d, exist = %d, need del = %d' % (len(allmemberidlist),len(existmemberidlist), len(needdelmemberidlist))

for memberid in needdelmemberidlist:
    r.delete('R:minfo:%s'%(memberid))
    needdelmembers += 1
    if needdelmembers%1000 == 0:
        print needdelmembers
  