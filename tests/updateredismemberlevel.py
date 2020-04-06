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
import redis


MEMBER_LEVEL_KEY = 'tyrant:L:%d'

conn  =  mysql.connect("localhost",user="tyrant",passwd="tyrant123456",db="tyrant",use_unicode=True, charset="utf8")
cursor = conn.cursor(cursorclass=mysql.cursors.DictCursor)

r = redis.StrictRedis()


sqlstr = "select * from tbl_tyrant_member_level"
count = cursor.execute(sqlstr)
rows = cursor.fetchall()
for row in rows:
	key = MEMBER_LEVEL_KEY % (row['id'])
	r.delete(key)
	r.hset(key, 'id', row['id'])
	r.hset(key, 'name', row['name'])
	r.hset(key, 'request', row['request'])
	r.hset(key, 'next_request', row['next_request'])
	r.hset(key, 'discount', row['discount'])
	r.hset(key, 'rate', row['rate'])
	r.hset(key, 'icon', row['icon'])

cursor.close()
conn.close()