#!/usr/bin/ruby
require 'json'
require 'net/http'

class CatData

	def self.getCatData(date)
		catBaseUrl = "http://cat.dp/cat/r/crash?op=appCrashLogJson&crashLogQuery.day=#{date}&crashLogQuery.startTime=00:00&crashLogQuery.endTime=23:59&crashLogQuery.appName=1&crashLogQuery.platform=2&crashLogQuery.dpid=&crashLogQuery.query=;;;;"

		# catBaseUrl = "http://cat.dp/cat/r/crash?op=appCrashLogJson&crashLogQuery.day=#{date}&crashLogQuery.startTime=00:00&crashLogQuery.endTime=23:59&crashLogQuery.appName=1&crashLogQuery.platform=2&crashLogQuery.dpid=&crashLogQuery.query=9.1.6;;;;"

		# catBaseUrl = "http://cat.dianpingoa.com/cat/r/crash?op=appCrashLog&crashLogQuery.day=2016-12-11&crashLogQuery.startTime=00:00&crashLogQuery.endTime=23:59&crashLogQuery.appName=1&crashLogQuery.platform=2&crashLogQuery.unionId=&crashLogQuery.type=-1&crashLogQuery.processor=-1&crashLogQuery.query=9.1.6;;;;"

		response = Net::HTTP.get_response(URI(catBaseUrl))
		resonseHash = JSON.parse(response.body)

		return resonseHash
	end

end


# def getCatPageJsonData (date)
# 	catBaseUrl = "http://cat.dp/cat/r/crash?op=appCrashLogJson&crashLogQuery.day=#{date}&crashLogQuery.startTime=00:00&crashLogQuery.endTime=23:59&crashLogQuery.appName=1&crashLogQuery.platform=2&crashLogQuery.dpid=&crashLogQuery.query=;;;;"

# 	response = Net::HTTP.get_response(URI(catBaseUrl))
# 	resonseHash = JSON.parse(response.body)

# 	return resonseHash

# end

# def getCrashTotalCount (catDateHash)
# 	totalCountStr = String.new
# 	totalCountStr = catDateHash["totalCount"]

# 	return totalCountStr
# end

# def getCategoryDate (catDateHash)
# 	cateDateArray = Array.new

# 	array = catDateHash["errors"]
# 	if array.count == 0 then
# 		return cateDateArray
# 	end

# 	array.each_index do |i|
# 		signCategoryHash = Hash.new
# 		name = String.new
# 		count = String.new
# 		crashLog = String.new

# 		hash = array[i]
# 		name = hash["msg"]
# 		count = hash["count"]
# 		idsArray = hash["ids"]

# 		if idsArray.count > 0 then
# 			idStr = idsArray[0]

# 			# 通过id获取crash log
# 			getSignDetailLogUrl = "http://cat.dp/cat/r/crash?op=appCrashLogDetail&id=#{idStr}&forceDownload=json"
# 			response = Net::HTTP.get_response(URI(getSignDetailLogUrl))
# 			resonseHash = JSON.parse(response.body)
# 			logInfoHash = resonseHash["crashLogDetailInfo"]
# 			if logInfoHash.size != 0 then	
# 				crashLog = logInfoHash["detail"]
# 			end
# 		end

# 		signCategoryHash["Name"] = "#{name}"
# 		signCategoryHash["Count"] = "#{count}"
# 		signCategoryHash["CrashLog"] = "#{crashLog}"

# 		cateDateArray.push(signCategoryHash)

# 	end

# 	return cateDateArray
# end

# def getAppVersionData (catDateHash)
# 	appVersionHash = Hash.new

# 	distributionsHash = catDateHash["distributions"]
# 	appVersionsHash = distributionsHash["appVersions"]
# 	versionArray = appVersionsHash["items"]

# 	if versionArray.count == 0 then
# 		return appVersionHash
# 	end

# 	versionArray.each_index do |i|
# 		hash = versionArray[i]
# 		verison = hash["title"]
# 		count = hash["number"]

# 		appVersionHash["#{verison}"] = count.to_i.to_s

# 	end

# 	return appVersionHash
# end

# def getIosVersionData (catDateHash)
# 	iosVersionHash = Hash.new

# 	distributionsHash = catDateHash["distributions"]
# 	iosVersionsHash = distributionsHash["platformVersions"]
# 	versionArray = iosVersionsHash["items"]

# 	if versionArray.count == 0 then
# 		return appVersionHash
# 	end

# 	versionArray.each_index do |i|
# 		hash = versionArray[i]
# 		count = String.new
# 		verison = hash["title"]
# 		count = hash["number"]

# 		iosVersionHash["#{verison}"] = count.to_i.to_s
# 	end

# 	return iosVersionHash
# end

# def getModulesData (catDateHash)
# 	modulesHash = Hash.new

# 	distributionsHash = catDateHash["distributions"]
# 	modules = distributionsHash["modules"]
# 	modulesArray = modules["items"]

# 	if modulesArray.count == 0 then
# 		return appVersionHash
# 	end

# 	modulesArray.each_index do |i|
# 		hash = modulesArray[i]
# 		count = String.new
# 		title = hash["title"]
# 		count = hash["number"]

# 		modulesHash["#{title}"] = count.to_i.to_s
# 	end

# 	return modulesHash
# end

# def storeSuccessSendElephantMs(date)
# 	sendElephant = SendElephantMsg.new()
# 	sendElephant.push_to_elephant("************ CrashDailyData **************\n
# 							   当前时间是：#{Time.now}\n
# 							   正在拉取 #{date} 的数据\n
# 							   已经成功入库\n
# 							   ******************************************")
# end

# def startHandle (date)
# 	startTime = Time.now
# 	willStoreHash = Hash.new

# 	# 获取cat页面Json
# 	returnJsonDataHash = getCatPageJsonData(date)

# 	# 时间
# 	willStoreHash["Date"] = "#{date}"

# 	# 获取Crash总个数
# 	totalCount = getCrashTotalCount(returnJsonDataHash)
# 	willStoreHash["CrashTotalCount"] = "#{totalCount}"

# 	# 获取Cat页面Crash分类信息（就是打开Cat页面我们看到的列表）
# 	categoryDataArray = getCategoryDate(returnJsonDataHash)
# 	willStoreHash["Category"] = categoryDataArray

# 	# 获取App不同版本的Crash量
# 	appVersionHash = getAppVersionData(returnJsonDataHash)
# 	willStoreHash["AppVersion"] = appVersionHash

# 	# 获取ios系统不同版本的Crash量
# 	iosVersionHash = getIosVersionData(returnJsonDataHash)
# 	willStoreHash["IosVersion"] = iosVersionHash

# 	# 获取分类Modules信息（就是打开Cat页面“模块”部分的数据）
# 	modulesHash = getModulesData(returnJsonDataHash)
# 	willStoreHash["Modules"] = modulesHash

# 	@db = CouchRest.database!("http://127.0.0.1:5984/crash_store")
# 	response = @db.save_doc({"log_daily" => willStoreHash, "_id" => "#{date}"})

# 	finishime = Time.now
# 	puts "*************************".green
# 	puts "当前时间是：#{startTime}".green
# 	puts "开始拉取：#{date}的数据".green
# 	puts "整个过程总耗时：".green + "#{format("%.1f",finishime - startTime).to_f}s".green
# 	puts "*************************".green

# 	storeSuccessSendElephantMs(date)

# 	# puts Date.today - 1

# end

# startHandle(ARGV[0])