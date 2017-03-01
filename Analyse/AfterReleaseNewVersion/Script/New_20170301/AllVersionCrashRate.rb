#!/usr/bin/ruby
require 'colored'
require 'time'
require_relative 'GetDAUData.rb'
require_relative 'GetCrashData.rb'

################## 分析所有版本及单个版本的Crash率等 ####################
# 																    #
# 该脚本会在控制台输出以下内容:                                         #
# 1.所有版本的Crash总量、Crash占比、Crash率、DAU占比 					#
# 2.单个版本的Crash总量、Crash占比、Crash率、DAU占比 		            #
# 																    #
#####################################################################

class AllVersionCrashRate

	$allVersionArray = Array.new
	$startDate = String.new
	$endDate = String.new
	$dauFilePath = String.new

	# 参数check
	def self.paramterCheck (allVersionArray,startDate,endDate,dauFilePath) 
		if allVersionArray.size == 0 || startDate.length == 0 || endDate.length == 0 || dauFilePath.length == 0 then
			puts "参数有问题，不能分析".red
		else
			$allVersionArray = allVersionArray
			$startDate = startDate
			$endDate = endDate
			$dauFilePath = dauFilePath
		end
	end

	def self.getDays
		return ((Time.parse($endDate) - Time.parse($startDate)) / 86400 + 1).to_i
	end

	# ******************************************************  DAU  ******************************************************

	# 获取某个时间段（一天或者多天）内所有版本的DAU总和数据
	def self.getTimeSlotAllVersionDAU (startDate ,days, dauDataArray)
		dauCount = 0

		for i in 1..days.to_i
			date = (Time.parse(startDate) + (i-1)*86400).strftime("%Y-%m-%d")
			dauDataArray.each_index do |i|
				line = dauDataArray[i]
				spoliteArray = line.lstrip.split()
				dauDate = spoliteArray[5]
				if dauDate == date then
					dauCount += spoliteArray[4].to_i
				end
			end
		end

		return dauCount
	end

	# 获取某个时间段（一天或者多天）内指定版本的DAU数据
	def self.getTimeSlotSingleVersionDAU (startDate ,days, dauDataArray, version)
		dauCount = 0

		for i in 1..days.to_i
			date = (Time.parse(startDate) + (i-1)*86400).strftime("%Y-%m-%d")
			dauDataArray.each_index do |i|
				line = dauDataArray[i]
				spoliteArray = line.lstrip.split()
				dauDate = spoliteArray[5]
				appVersion = spoliteArray[3]
				if (dauDate == date) && (appVersion == version) then
					dauCount += spoliteArray[4].to_i
				end
			end
		end

		return dauCount
	end

	# get dau data
	def self.getDauData (filePath)
		dauArray = Array.new
		dauArray = GetDAUData.getDAUDataFromFile(filePath)

		return dauArray
	end

	# dau数据在控制台输出
	def self.outPutDauData (dauDataArray)
		puts "\n******************** DAU ********************"
		days = getDays

		# all version
		allVersionDAUCount = getTimeSlotAllVersionDAU($startDate, days, dauDataArray)
		puts "All Version DAU: #{allVersionDAUCount}".green

		# single version
		$allVersionArray.each_index do |i|
			versionStr = $allVersionArray[i]
			singleVersiondDAU = getTimeSlotSingleVersionDAU($startDate, days, dauDataArray, versionStr)
			dauRate = ((singleVersiondDAU.to_f / allVersionDAUCount).round(5) * 100).round(2)
			puts "#{versionStr}_Version DAU: #{singleVersiondDAU}   DAU占比: #{dauRate}%".green

		end
	end

	# ******************************************************  Crash  ******************************************************

	# 获取一天内所有版本的Crash总和
	def self.getSingleDayAllVersionCrashCount (catDateHash)
		totalCount = 0
		totalCount = catDateHash["totalCount"].to_i

		return totalCount
	end

	# 获取一天内指定版本的Crash量
	def self.getSingleDaySingleVersionCrashCount (catDateHash, appVersion)
		singleVersionCrashCount = 0

		distributionsHash = catDateHash["distributions"]
		appVersionsHash = distributionsHash["appVersions"]
		versionArray = appVersionsHash["items"]

		if versionArray.count == 0 then
			return singleVersionCrashCount
		end

		versionArray.each_index do |i|
			hash = versionArray[i]
			count = String.new
			verison = hash["title"]
			count = hash["number"]

			if verison == appVersion then
				singleVersionCrashCount = count.to_i
				break
			end
		end

		return singleVersionCrashCount
	end

	def self.get805VersionBeforeAndAfterCrashCount (catDateHash)
		before805VersionCrashCount = 0
		after805VersionCrashCount = 0

		distributionsHash = catDateHash["distributions"]
		appVersionsHash = distributionsHash["appVersions"]
		versionArray = appVersionsHash["items"]

		if versionArray.count == 0 then
			return singleVersionCrashCount
		end

		versionArray.each_index do |i|
			hash = versionArray[i]
			count = String.new
			verison = hash["title"]
			count = hash["number"]

			# 把原始的版本号字符串进行加工，去掉所有的小数点，然后取前三位，转换成整数，和805进行比较
			handleVerison = (verison.gsub(".",""))[0,3].to_i
			if handleVerison >= 805 then
				after805VersionCrashCount += count.to_i
			else
				before805VersionCrashCount += count.to_i
			end

		end

		return Hash["before805" => before805VersionCrashCount, "after805" => after805VersionCrashCount]
	end

	# get crash data
	def self.getCrashData
		catDataHash = Hash.new
		days = getDays

		for i in 1..days.to_i
			date = (Time.parse($startDate) + (i-1)*86400).strftime("%Y-%m-%d")
			catReturnHash = GetCrashData.getSingleDayAllVersionCrash(date)
			catDataHash["#{date}"] = catReturnHash
		end

		return catDataHash
	end

	# crash数据在控制台输出
	def self.outPutCrashData (crashDataHash,dauDataArray)
		puts "\n******************** Crash ********************"
		days = getDays

		# all verison
		crashTotal = 0
		crashDataHash.keys.each do |k| 
			singleDayCrashHash = crashDataHash[k]
			crashTotal += getSingleDayAllVersionCrashCount(singleDayCrashHash)
		end
		# dau
		allVersionDAU = getTimeSlotAllVersionDAU($startDate, days, dauDataArray)
		# crash率
		allVersionCrashRate = ((crashTotal.to_f / allVersionDAU).round(5) * 1000).round(2)
		puts "All Version Crash Total: #{crashTotal}   Crash率: #{allVersionCrashRate}‰".green

		# single version
		$allVersionArray.each_index do |i|
			versionStr = $allVersionArray[i]

			crashCount = 0
			crashDataHash.keys.each do |k| 
				singleDayCrashHash = crashDataHash[k]
				crashCount += getSingleDaySingleVersionCrashCount(singleDayCrashHash, versionStr)
			end
			# Crash占比
			crashRate = ((crashCount.to_f / crashTotal).round(5) * 100).round(2)

			# dau
			singleVersiondDAU = getTimeSlotSingleVersionDAU($startDate, days, dauDataArray, versionStr)
			# crash率
			singleVersionCrashRate = ((crashCount.to_f / singleVersiondDAU).round(5) * 1000).round(2)

			puts "#{versionStr}_Version Crash Count: #{crashCount}   Crash占比: #{crashRate}%   Crash率: #{singleVersionCrashRate}‰".green
		end

		# 805版本前僵尸Crash
		before805CrashCount = 0
		after805CrashCount = 0
		crashDataHash.keys.each do |k| 
			singleDayCatHash = crashDataHash[k]
			resultHash = get805VersionBeforeAndAfterCrashCount(singleDayCatHash)
			before805CrashCount += resultHash["before805"]
			after805CrashCount += resultHash["after805"]
		end
		totalCrashCount = before805CrashCount + after805CrashCount
		zombieCrashRatio = ((before805CrashCount.to_f/totalCrashCount.to_f).round(4) * 100).round(2)
		puts "805版本前:#{before805CrashCount}  805版本后:#{after805CrashCount}  Crash总量:#{totalCrashCount}  僵尸Crash占比:#{zombieCrashRatio}%".green

	end

	# ******************************************************  入口  ******************************************************

	def self.statrAnalyseCrashRate (allVersionArray,startDate,endDate,dauFilePath)

		puts "----------------- Start Analyse -----------------".yellow
		puts "\n开始分析所有版本及单个版本的Crash率..."

		# 参数check
		paramterCheck(allVersionArray,startDate,endDate,dauFilePath)

		# dau数据
		dauDataArray = getDauData($dauFilePath)
		outPutDauData(dauDataArray)

		# crash数据
		catDataHash = getCrashData
		outPutCrashData(catDataHash,dauDataArray)

	end

end
