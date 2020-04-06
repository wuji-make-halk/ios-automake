#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
from PIL import Image
from pylab import *

class ImageManager(object):
	"""docstring for ImageManager"""
	def __init__(self, arg):
		super(ImageManager, self).__init__()
		self.arg = arg
		
		#open图片
		try:
			self.image = Image.open(self.arg)
		except Exception,e:
			print Exception,":",e


	def __del__(self):
		self.image.close()

	#图片格式转换
	def convertImageToPNG(self, newName):
		try:
			self.image.save(newName,"PNG")
		except Exception,e:
			print Exception,":",e

	#图片变灰（智慧手环定制）
	def convertImageGray(self, newName):
		try:
			img = Image.open(self.arg).convert('LA')
			img.save(newName,"PNG")
		except Exception,e:
			print Exception,":",e

	#将图标/启动页转成指定大小
	def convertImageToSize(self, size1, size2, newName):
		try:
			newImage = self.image.resize((size1,size2),Image.ANTIALIAS)
			newImage.save(newName,"PNG")
		except Exception,e:
			print Exception,":",e
	def close(self):
		self.image.close()


#testtest
#1、图片大小转换180->120
#img = Image.open('/Users/zhangzhipeng/Documents/zhangzp-work/keepRapid/python/ios-package/source/src/ios-smartband-smartwristband/180x180.png')
#newImg = img.resize((120,120),Image.ANTIALIAS)
#ewImg.save('/Users/zhangzhipeng/Documents/zhangzp-work/keepRapid/python/ios-package/source/src/ios-smartband-smartwristband/120x120.png')

#1、图片变灰
#img = Image.open('/Users/zhangzhipeng/Documents/zhangzp-work/keepRapid/python/ios-package/source/src/ios-smartband-smartwristband/icon_bs_logo.png').convert('LA')
#img.save('/Users/zhangzhipeng/Documents/zhangzp-work/keepRapid/python/ios-package/source/src/ios-smartband-smartwristband/icon_bs_logo2.png')
#2、图片格式转换
#img.save("save.png","PNG")
#3、改变图片透明度
#img2 = img.point(lambda p: p * 0.5)
#img2.save('/Users/zhangzhipeng/Documents/zhangzp-work/keepRapid/python/ios-package/source/src/ios-smartband-smartwristband/icon_bs_logo2.png')
