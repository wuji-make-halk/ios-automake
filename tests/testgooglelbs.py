#!/usr/bin/python
# -*- coding: UTF-8 -*-
# SMGP v3.0 api file
import sys
import os
import socket
import json
import httplib


lbsinfo = dict()
lbsinfo['homeMobileCountryCode'] = 460
lbsinfo['homeMobileNetworkCode'] = 0
lbsinfo['radioType'] = 'gsm'
celltower = list()
lbsinfo['cellTowers'] = celltower


cellinfo = dict()
cellinfo['cellId'] = 4053
cellinfo['locationAreaCode'] = 9349
cellinfo['mobileCountryCode'] = 460
cellinfo['mobileNetworkCode'] = 0
cellinfo['age'] = 0
cellinfo['signalStrength'] = -50
celltower.append(cellinfo)

cellinfo = dict()
cellinfo['cellId'] = 4201
cellinfo['locationAreaCode'] = 9349
cellinfo['mobileCountryCode'] = 460
cellinfo['mobileNetworkCode'] = 0
cellinfo['age'] = 0
cellinfo['signalStrength'] = -50
celltower.append(cellinfo)

cellinfo = dict()
cellinfo['cellId'] = 3892
cellinfo['locationAreaCode'] = 10342
cellinfo['mobileCountryCode'] = 460
cellinfo['mobileNetworkCode'] = 0
cellinfo['age'] = 0
cellinfo['signalStrength'] = -50
celltower.append(cellinfo)

cellinfo = dict()
cellinfo['cellId'] = 4051
cellinfo['locationAreaCode'] = 9349
cellinfo['mobileCountryCode'] = 460
cellinfo['mobileNetworkCode'] = 0
cellinfo['age'] = 0
cellinfo['signalStrength'] = -50
celltower.append(cellinfo)

jsonbody = json.dumps(lbsinfo)

headers = dict()
headers['Content-Type'] = 'application/json'

conn = httplib.HTTPSConnection("www.googleapis.com")
conn.request("POST", "/geolocation/v1/geolocate?key=AIzaSyAIARgh8cDSkHrgV9Srv5rkVarsLxtdRkQ", jsonbody, headers)
response = conn.getresponse()
print response.read()



