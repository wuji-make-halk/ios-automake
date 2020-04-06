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
import MySQLdb as mysql
import random

conn  =  mysql.connect("localhost",user="tyrant",passwd="tyrant123456",db="tyrant",use_unicode=True, charset="utf8")
cursor = conn.cursor(cursorclass=mysql.cursors.DictCursor)

sqlstr = "SELECT * from tbl_tyrant_task_avatar_info"
cursor.execute(sqlstr)
rows = cursor.fetchall()
avatar = dict()
avataradd = dict()
for row in rows:
	avatar['%s:%s' % (row['snsid'], row['owner_id'])] = row



sqlstr = "select * from tbl_tyrant_task"
count = cursor.execute(sqlstr)
rows = cursor.fetchall()
for row in rows:
#	if row['action_type'] != 1:
#		continue
	key = '%s:%s' % (row['task_account_id'],row['owner_id'])
	if key in avatar:
		continue
	else:
		t = dict()
		avataradd[key] = t
		t['owner_id'] = row['owner_id']
		t['snsid'] = row['task_account_id']

	if row['action_type'] == 1:
		t['sns_name'] = row['task_name']
		t['sns_img'] = row['task_img']
		t['sns_description'] = row['task_description']
	else:
		t['sns_name'] = u'未知'
		t['sns_img'] = ''
		t['sns_description'] = ''
#for a in avataradd:
#	member_id = a.split(':')[1]
#	sqlstr = "select * from tbl_tyrant_member where id = '%s'" % (member_id)
#	cursor.execute(sqlstr)
#	row =cursor.fetchone()
#	print '%s:%s:%s:%s\n' % (a,row['name'],row['create_time'],row['last_time'])
#	print '%s' % (avataradd[a]['sns_name'].encode('UTF-8'))
#	print '\n'
#	print avataradd[a]
#	print '\r\n'
for key in avataradd:
	anonymous_name = u'匿名用户%s' % (random.randint(0,9999999))
	sql = "INSERT into tbl_tyrant_task_avatar_info (provider_type,owner_id,snsid,sns_name,sns_img,sns_description,is_anonymous,anonymous_name) values (%d,'%s','%s','%s','%s','%s',%d,'%s')" % ( 1, avataradd[key]['owner_id'], avataradd[key]['snsid'], avataradd[key]['sns_name'], avataradd[key]['sns_img'], avataradd[key]['sns_description'],0,anonymous_name)
	print sql
	cursor.execute(sql)

conn.commit()
cursor.close()
conn.close()

