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

chargedict = dict()

sqlstr = "select * from tbl_tyrant_trade_info where trade_state = 1000"
count = cursor.execute(sqlstr)
rows = cursor.fetchall()
for row in rows:
	if row['member_id'] in chargedict:
		chargedict[row['member_id']] += row['pay_amount']
	else:
		chargedict[row['member_id']] = row['pay_amount']

for member_id in chargedict:
	sqlstr = "SELECT * from tbl_tyrant_member_level where request <= %f and next_request > %f" % (chargedict[member_id], chargedict[member_id])
	cursor.execute(sqlstr)
	row = cursor.fetchone()
	if row:
		level = row['id']
	else:
		level = 0

	sqlstr = "UPDATE tbl_tyrant_member set total_charge = %f,level = %d where id = '%s'" % (chargedict[member_id], level, member_id)
	print sqlstr
	cursor.execute(sqlstr)



conn.commit()
cursor.close()
conn.close()