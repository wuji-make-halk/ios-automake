#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
import json
import common
from command import Command
from BUConfig import BUConfig
from fileManager import FileManager

class Xcode(object):
	"""docstring for Xcode"""
	def __init__(self):
		super(Xcode, self).__init__()

	#构建工程
	def build(self):
	
		if self.isUsable():
			#直接打包
			if not self.clean():
				return False
			if not self.archive():
				return False
			if not self.export():
				return False
		else:
			#先获取打包信息
			if not self.importKeychain():
				print "failed to importKeychain!!!"
				return False
			if not self.getTeamId():
				print "failed to getTeamId!!!"
				return False
			if not self.getSignId():
				print "failed to getSignId!!!"
				return False
			if not self.importProvision():
				print "failed to importProvision!!!"
				return False
			if not self.isUsable():
				print "profile can not use!!!"
				return False
			if not self.clean():
				print "failed to clean!!!"
				return False
			if not self.archive():
				print "failed to archive!!!"
				return False
			if not self.export():
				print "failed to export!!!"
				return False

		return True

	#判断teamId、signId、provisionId是否可用
	def isUsable(self):

		if (BUConfig.teamId == None 
		or len(BUConfig.teamId) <= 0):
			return False
		if (BUConfig.signId == None 
		or len(BUConfig.signId) <= 0):
			return False
		if (BUConfig.provisionId == None 
		or len(BUConfig.provisionId) <= 0):
			return False

		return True

	#导入钥匙串
	def importKeychain(self):
		#1、先判断p12文件是否存在
		p12Path = common.resoureDire + '/' + BUConfig.p12File
		if not FileManager.isFileExist(p12Path):
			print "%s文件不存在,无法导入" %p12Path
			return False


		#2、解锁Mac的钥匙串
		result = Command.execCmd("security unlock-keychain -p %s $HOME/Library/Keychains/login.keychain" %BUConfig.hostPasswd)

		if not result:
			print "Error:解锁mac出错！！！"
			return False

		#3、导入签名证书(p12)到Mac的钥匙串
		#result = Command.execCmd("security import %s -k $HOME/Library/Keychains/login.keychain -P %s -A" %(p12Path, BUConfig.p12Passwd))
		result = Command.execCmd("security import %s -k $HOME/Library/Keychains/login.keychain -P %s -T /usr/bin/codesign" %(p12Path, BUConfig.p12Passwd))
		
		if not result:
			print "Error:导入p12文件出错！！！"
			return False

		return True

        

	#获取teamId
	def getTeamId(self):
		#1、先判断p12文件是否存在
		p12Path = common.resoureDire + '/' + BUConfig.p12File;
		if not FileManager.isFileExist(p12Path):
			print "%s文件不存在,无法获取TeamId" %p12Path
			return False

		#截取UID=和/CN之间的teamid
		#teamId = os.popen("openssl pkcs12 -in %s/%s -nodes -passin pass:\"%s\" | openssl x509 -noout -subject | sed 's/.*UID=\(.*\)\/CN.*/\1/'" %(resourcePath,signfile,filePasswd)).read()
        
		#上面的代码在命令行实测可以，但是这里没得到结果？？？？

		#在不同的机子上，有的分割符是\有的分隔符是,所以要先判断分隔符
		info = Command.getCmdResult("openssl pkcs12 -in %s -nodes -passin pass:\"%s\" | openssl x509 -noout -subject" %(p12Path, BUConfig.p12Passwd))

		#判断是否包含/
		if info.find('/') != -1:
			BUConfig.teamId = Command.getCmdResult("openssl pkcs12 -in %s -nodes -passin pass:\"%s\" | openssl x509 -noout -subject |  cut -d '/' -f 2 | cut -d '=' -f 2" %(p12Path, BUConfig.p12Passwd))
		if info.find(',') != -1:
			BUConfig.teamId = Command.getCmdResult("openssl pkcs12 -in %s -nodes -passin pass:\"%s\" | openssl x509 -noout -subject |  cut -d ',' -f 1 | cut -d '=' -f 3" %(p12Path, BUConfig.p12Passwd))

 
		#去掉开头的空格
		BUConfig.teamId = BUConfig.teamId.strip()

		print "BUConfig.teamId = %s" %BUConfig.teamId
		if len(BUConfig.teamId) <= 0:
			return False

		return True

	#获取signId
	def getSignId(self):
		#1、先判断p12文件是否存在
		p12Path = common.resoureDire + '/' + BUConfig.p12File;
		if not FileManager.isFileExist(p12Path):
			print "%s文件不存在,无法获取SignId" %p12Path
			return False

		#4、截取CN=和/OU之间的signId
		#signId = os.popen("openssl pkcs12 -in %s/%s -nodes -passin pass:\"%s\" | openssl x509 -noout -subject | sed 's/.*CN=\(.*\)\/OU.*/\1/'" %(resourcePath,signfile,filePasswd)).read()
		
		#在不同的机子上，有的分割符是\有的分隔符是,所以要先判断分隔符
		info = Command.getCmdResult("openssl pkcs12 -in %s -nodes -passin pass:\"%s\" | openssl x509 -noout -subject" %(p12Path, BUConfig.p12Passwd))

		#判断是否包含/
		if info.find('/') != -1:
			BUConfig.signId = Command.getCmdResult("openssl pkcs12 -in %s -nodes -passin pass:\"%s\" | openssl x509 -noout -subject |  cut -d '/' -f 3 | cut -d '=' -f 2" %(p12Path, BUConfig.p12Passwd))
		if info.find(',') != -1:
			BUConfig.signId = Command.getCmdResult("openssl pkcs12 -in %s -nodes -passin pass:\"%s\" | openssl x509 -noout -subject |  cut -d ',' -f 2 | cut -d '=' -f 2" %(p12Path, BUConfig.p12Passwd))
		#去掉开头的空格
		BUConfig.signId = BUConfig.signId.strip()

		#从p12文件中获取到的signid，有的开头会有空格，有的开头有"符号，所以
		BUConfig.signId = BUConfig.signId.replace("\"","");

		print "BUConfig.signId = %s" %BUConfig.signId

		if len(BUConfig.signId) <= 0:
			return False

		return True

	#导入.mobileprovision文件
	def importProvision(self):
		#1、先判断provision文件是否存在
		provisionPath = common.resoureDire + '/' + BUConfig.provisionFile;
		if not FileManager.isFileExist(provisionPath):
			print "%s文件不存在,无法导入provision文件" %provisionPath
			return False

		#安装xxxx.mobileprovision文件
		BUConfig.provisionId = Command.getCmdResult("grep 'UUID' -A1 -a '%s' | grep -io \"[-A-Z0-9]\{36\}\"" %provisionPath)
		
		print "BUConfig.provisionId = %s" %BUConfig.provisionId 

		if len(BUConfig.provisionId) <= 0:
			return False
    
		#如果该目录不存在，先创建
		if not FileManager.isFileExist(common.provisionDire):
			result = Command.execCmd("mkdir -p %s" %common.provisionDire)
			if not result:
				print "Error:创建目录(%s)失败" %common.provisionDire
				return False

		BUConfig.provisionFile = '%s.mobileprovision' %BUConfig.provisionId 

		
		#拷贝
		return FileManager.copyFile(provisionPath, common.provisionDire + '/' + BUConfig.provisionFile)
		
	#清理工程
	def clean(self):
		#清理bin目录
		result = Command.execCmd("cd %s; rm -rf *.ipa" %common.binDire) 
		if not result:
			print "Error:清理bin目录失败！！！"
			return False

		projectPath = common.targetDire + '/' + BUConfig.projectDire
		result = Command.execCmd("cd %s; xcodebuild clean -project %s.xcodeproj -alltargets" %(projectPath, BUConfig.projectName))
		if not result:
			print "Error:clean工程失败！！！"
			return False

		print "清理工程成功..."
		return True

	#archive工程
	def archive(self):
		projectPath = common.targetDire + '/' + BUConfig.projectDire
		result = Command.execCmd("cd %s; xcodebuild archive -project %s.xcodeproj -scheme %s -archivePath ./%s CODE_SIGN_IDENTITY=\"%s\" DEVELOPMENT_TEAM=\"%s\" PROVISIONING_PROFILE=\"%s\" PROVISIONING_PROFILE_SPECIFIER=\"%s\"" %(projectPath, BUConfig.projectName, BUConfig.targetName, BUConfig.targetName, BUConfig.signId, BUConfig.teamId, BUConfig.provisionId, BUConfig.provisionName))
		if not result:
			print "Error:archive工程失败！！！"
			return False
		print "archive工程成功..."
		return True

	#export archive
	def export(self):
		projectPath = common.targetDire + '/' + BUConfig.projectDire
		result = Command.execCmd("cd %s; xcodebuild -exportArchive -archivePath ./%s.xcarchive -exportPath %s/%s -exportFormat ipa -exportProvisioningProfile \"%s\"" %(projectPath, BUConfig.targetName, common.binDire, BUConfig.targetName, BUConfig.provisionName))
		if not result:
			print "Error:export工程失败！！！"
			return False
		print "export工程成功..."
		return True

	#上传蒲公英
	def uploadPgyer(self):
		ipaPath = common.binDire + '/' + BUConfig.ipaName
		#ipaPath = "/Users/zhangzhipeng/Documents/zhangzp-work/keepRapid/python/ios-package/source/bin/smartwristband.ipa"
		result = Command.getCmdResult("curl -F file=@%s -F uKey=%s -F _api_key=%s %s" %(ipaPath ,common.pgyerUserkey, common.pgyerApiKey ,common.pgyerAddr))
		print "restult = %s" %result

		try:
			msg = json.loads(result)
			errcode = msg['code']
			print errcode
			if errcode == 0:
		 		data = msg['data']
		 		cutUrl = data['appShortcutUrl']

		 		print cutUrl

		 		return common.pgyerUrl + '/' + cutUrl
			else:
		 		return None
		except Exception,e:
			print Exception,":",e
	
	def uploadAppStore(self):
		pass









