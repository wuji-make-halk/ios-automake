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

avatar = dict()

sqlstr = "select * from tbl_tyrant_task_avatar_info"
count = cursor.execute(sqlstr)
rows = cursor.fetchall()
for row in rows:
	name = u'匿名用户%s' % (random.randint(0,9999999))
	sqlstr = "UPDATE tbl_tyrant_task_avatar_info set anonymous_name = '%s' where id = %d" % (name, row['id'])
	print sqlstr
	cursor.execute(sqlstr)

conn.commit()
cursor.close()
conn.close()