#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys

#工作目录
workDire = os.getenv('PACKAGE')

#源代码目录
srcDire = workDire + '/source/src'

#目标目录
targetDire = workDire + '/source/target'

#资源文件目录
resoureDire = workDire + '/source/resource'

#bin文件目录
binDire = workDire + '/source/bin'

#.mobileprovision文件目录
provisionDire = "$HOME/Library/MobileDevice/Provisioning\ Profiles"

templateFile = "test.json"

url = None

vid = None
appName = None
topic = None

#蒲公英地址
pgyerAddr = "https://www.pgyer.com/apiv1/app/upload"

#蒲公英的user key
pgyerUserkey = "dbb65d32519e772b810834ce63ce32e4"

#蒲公英的api Key
pgyerApiKey = "c31e4fd83a99a5e830ed5ac01505c19e"

#蒲公英返回的ipa下载地址
pgyerAppUrl = None

pgyerUrl = "https://www.pgyer.com"

#连接手环显示logo（智慧手环定制）
connectIconName = "icon_bs_logo.png"
#断开手环显示logo（智慧手环定制）
disconnIconName = "icon_bs_logo_black.png"


#启动图标和启动页的目录
ImagesDire = "Images.xcassets"

#180x180的应用图标
appIcon180 = "180x180.png"
#120x120的应用图标
appIcon120 = "120x120.png"
#120x120-1的应用图标
appIcon120_1 = "120x120-1.png"
#114x114的应用图标
appIcon114 = "114x114.png"
#87x87的应用图标
appIcon87 = "87x87.png"
#80x80的应用图标
appIcon80 = "80x80.png"
#58x58的应用图标
appIcon58 = "58x58.png"
#57x57的应用图标
appIcon57 = "57x57.png"
#29x29的应用图标
appIcon29 = "29x29.png"

#320x480的启动页面
launchImage480 = "320x480.png"
#640x960的启动页面
launchImage960 = "640x960.png"
#640x960-1的启动页面
launchImage960_1 = "640x960-1.png"
#640x1136的启动页面
launchImage1136 = "640x1136.png"
#640x1136-1的启动页面
launchImage1136_1 = "640x1136-1.png"
#750x1334的启动页面
launchImage1334 = "750x1334.png"
#1242x2208的启动页面
launchImage2208 = "1242x2208.png"

















