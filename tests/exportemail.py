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

last_time = sys.argv[1]

sqlstr = "SELECT * from tbl_tyrant_member where last_time < '%s' or last_time is NULL" % (last_time)

cursor.execute(sqlstr)
rows = cursor.fetchall()
emaillist = list()
for row in rows:
	emaillist.append(row['email'])

emailstr = ';'.join(emaillist)

f = open('emaillist.txt', 'wb')
f.write(emailstr)
f.flush()
f.close()

cursor.close()
conn.close()