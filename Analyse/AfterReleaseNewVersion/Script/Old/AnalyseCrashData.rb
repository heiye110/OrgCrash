#!/usr/bin/ruby
require 'json'
require 'colored'
require 'time'
require_relative 'DPAppData.rb'
require_relative 'CatData.rb'

def getCurrentTime 
	return "#{Time.new.strftime("%Y-%m-%d")}"
end

def getDPAppDAUData (startDate, endDate, appPlatform, appVersion)
	dau = 0
	dateArray = DPAppData.getUV(startDate, endDate, appPlatform, appVersion)
	if dateArray.length == 0 then
		return dau
	end

	dateArray.each_index do |i|
		dpAppDataHash = dateArray[i]
		dau += dpAppDataHash["uv"].to_i
	end

	return dau
end

def getCatData (startDate, days)
	catDataHash = Hash.new

	for i in 1..days.to_i
		date = (Time.parse(startDate) + (i-1)*86400).strftime("%Y-%m-%d")
		catReturnHash = CatData.getCatData(date)
		catDataHash["#{date}"] = catReturnHash
	end

	return catDataHash
end

def getSingleDayCrashTotalCount (catDateHash)
	totalCount = 0
	totalCount = catDateHash["totalCount"].to_i

	return totalCount
end

def getAppAllVersionCrashTotalCount (catDateHash)
	iosVersionHash = Hash.new

	distributionsHash = catDateHash["distributions"]
	appVersionsHash = distributionsHash["appVersions"]
	versionArray = appVersionsHash["items"]

	if versionArray.count == 0 then
		return appVersionHash
	end

	versionArray.each_index do |i|
		hash = versionArray[i]
		count = String.new
		verison = hash["title"]
		count = hash["number"]

		iosVersionHash["#{verison}"] = count.to_i.to_s
	end

	return iosVersionHash
end

def getAppSingleVersionCrashCount (catDateHash, appVersion)
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

def get805VersionBeforeAndAfterCrashCount (catDateHash)
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

def getCrashTotalCount (catDateHash)
	totalCountStr = String.new
	totalCountStr = catDateHash["totalCount"]

	return totalCountStr
end

def getCrashCategoryData (catDateHash)
	modulesHash = Hash.new

	array = catDateHash["errors"]
	if array.count == 0 then
		return modulesHash
	end

	array.each_index do |i|
		hash = array[i]
		name = hash["msg"]
		count = hash["count"]

		modulesHash["#{name}"] = count.to_i

	end

	return modulesHash
end

def writeCrashCateroryToFile (categoryHash,crashTotalCount)
	crashRateFile = "/Users/lmc/Desktop/Crash/发新版后Crash分析报告/category.log"
	if File.exist?(crashRateFile) then
		File.delete(crashRateFile)
	end
	newfile = File.new(crashRateFile,"w") 
	categoryHash.keys.each do |k| 
		crashCount = categoryHash[k]
		if crashTotalCount
			crashRate = ((crashCount.to_f / crashTotalCount).round(5) * 100).round(2)
			newfile.syswrite ("#{k}##{crashCount}##{crashRate}\n")
		else
			newfile.syswrite ("#{k}##{crashCount}\n")
		end
	end
	
end

# ******************************************************  入口  ******************************************************

# 分析日期，起始日期--结束日期
# willAnalyseDate = getCurrentTime
willAnalyseStartDate = "2017-01-07"
willAnalyseEndDate = "2017-01-07"

days = ((Time.parse(willAnalyseEndDate) - Time.parse(willAnalyseStartDate)) / 86400 + 1).to_i

# 分析的App版本，如：9.0.8  这个值可选，没有该值时默认获取和分析所有版本的数据
willAnalyseAppVersion = ""
willAnalyseAppVersion = "9.1.2"


puts "Start Analyse" + " #{willAnalyseAppVersion}".green + " <#{willAnalyseStartDate}> - <#{willAnalyseEndDate}> #{days} Days ".green + "Crash Data..."

#App Data
dpAppDAUData = getDPAppDAUData(willAnalyseStartDate, willAnalyseEndDate, "ios", willAnalyseAppVersion)
puts "iOS #{willAnalyseAppVersion} DAU: #{dpAppDAUData}".green

#Cat Data
catDataHash = getCatData(willAnalyseStartDate, days)
if catDataHash then
	if willAnalyseAppVersion.length == 0 then 
		# 所有App版本
		crashTotal = 0
		catDataHash.keys.each do |k| 
			singleDayCatHash = catDataHash[k]
			crashTotal += getSingleDayCrashTotalCount(singleDayCatHash)
			# puts "<#{k}> Total Crash :#{getSingleDayCrashTotalCount(singleDayCatHash)}"
		end

		puts "Crash Total Count: #{crashTotal}".green
	else
		# 指定App版本
		crashCount = 0
		catDataHash.keys.each do |k| 
			singleDayCatHash = catDataHash[k]
			crashCount += getAppSingleVersionCrashCount(singleDayCatHash, willAnalyseAppVersion)
			# puts "<#{k}> #{willAnalyseAppVersion} Crash :#{getAppSingleVersionCrashCount(singleDayCatHash, willAnalyseAppVersion)}"
		end
		puts "#{willAnalyseAppVersion} Crash Count: #{crashCount}".green
	end
	
end

# Crash率
if willAnalyseAppVersion.length == 0 then
	# 所有版本
	allVersionCrashRate = ((crashTotal.to_f / dpAppDAUData).round(5) * 1000).round(2)
	puts "所有版本整体Crash率: #{allVersionCrashRate}‰".green
else
	# 指定的单个版本
	singleVersionCrashRate = ((crashCount.to_f / dpAppDAUData).round(5) * 1000).round(2)
	puts "#{willAnalyseAppVersion} 版本Crash率: #{singleVersionCrashRate}‰".green
end

# 符号化前服务开始前后Crash统计(805版本开始)
if catDataHash then

	before805CrashCount = 0
	after805CrashCount = 0
	catDataHash.keys.each do |k| 
		singleDayCatHash = catDataHash[k]
		resultHash = get805VersionBeforeAndAfterCrashCount(singleDayCatHash)
		before805CrashCount += resultHash["before805"]
		after805CrashCount += resultHash["after805"]
	end

	totalCrashCount = before805CrashCount + after805CrashCount
	zombieCrashRatio = ((before805CrashCount.to_f/totalCrashCount.to_f).round(4) * 100).round(2)
	# puts "before805CrashCount:#{before805CrashCount}"
	# puts "after805CrashCount:#{after805CrashCount}"
	puts "805版本前:#{before805CrashCount}  805版本后:#{after805CrashCount}  Crash总量:#{totalCrashCount}  僵尸Crash占比:#{zombieCrashRatio}%".green
	
end


# 每个模块的Crash数据
if catDataHash then

	catDataHash.keys.each do |k| 
		singleDayCatHash = catDataHash[k]
		categoryReturnHash = getCrashCategoryData(singleDayCatHash)

		categoryReturnHash.keys.each do |k| 
			crashCountNum = categoryReturnHash[k]
			# puts "#{k} :#{crashCount}"
		end

		# 写到文件中
		writeCrashCateroryToFile(categoryReturnHash,crashCount)
	end
	
end





