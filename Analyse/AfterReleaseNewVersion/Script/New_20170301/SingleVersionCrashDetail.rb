#!/usr/bin/ruby
require 'colored'
require 'json'
require_relative 'GetCrashData.rb'

###################### 获取某一个某个版本所有的Crash详细信息 ######################
# 																		     #
# 该脚本会将某一天某个版本详细的Crash信息写入到指定的log文件中 						 #
# 内容包括：Crash类型 Crash数量 Crash占比										 #
# 																		     #
##############################################################################


class SingleVersionCrashDetail

	# 从cat获取数据
	def self.getCrashDataFromCat (date, version)
		crashHash = Hash.new
		crashHash = GetCrashData.getSingleDaySingleVersionCrash(date,version)

		return crashHash
	end

	# 从Cat获取的数据中找出我们统计所需要的数据
	def self.getCrashCategoryData (catDateHash)
		modulesHash = Hash.new

		array = catDateHash["errors"]
		if array.count == 0 then
			return modulesHash
		end

		array.each_index do |i|
			hash = array[i]
			name = hash["msg"]
			count = hash["count"]
			if name
				modulesHash["#{name.squeeze(" ")}"] = count.to_i
			end

		end

		return modulesHash
	end

	def self.writeCrashCateroryToFile (categoryHash, crashTotalCount, filePath)
		if File.exist?(filePath) then
			puts "有旧文件存在，正在删除...".red
			File.delete(filePath)
		end
		newfile = File.new(filePath,"w") 
		categoryHash.keys.each do |k| 
			crashCount = categoryHash[k]
			if crashTotalCount
				crashRate = ((crashCount.to_f / crashTotalCount).round(5) * 100).round(2)
				newfile.syswrite ("#{k}##{crashCount}##{crashRate}%\n")
			else
				newfile.syswrite ("#{k}##{crashCount}\n")
			end
		end

		puts "新的文件写入完成"
	
	end


	def self.analyseSingleVersionCrash (date, version, createFilePath)
		puts "\n\n开始分析 #{date} #{version} 版本的详细Crash信息..."

		if date.length == 0 || version.length == 0 then	
			puts "参数有问题，不能进行分析".red
		else
			getCrashHash = getCrashDataFromCat(date, version)
			categoryReturnHash = getCrashCategoryData(getCrashHash)

			# categoryReturnHash.keys.each do |k| 
			# 	crashCountNum = categoryReturnHash[k]
			# 	puts "#{k} :#{crashCountNum}"
			# end

			totalCount = getCrashHash["totalCount"].to_i
			# 写到文件中
			writeCrashCateroryToFile(categoryReturnHash,totalCount,createFilePath)

			puts "\n----------------- Analyse End -----------------".yellow

		end
		
	end

end
