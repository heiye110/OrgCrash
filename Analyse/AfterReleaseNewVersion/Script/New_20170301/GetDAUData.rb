#!/usr/bin/ruby
require 'colored'

################################### 获取DAU数据 ##########################
# 																		#
# 调用该脚本需要传进来一个参数  										    #
# dauFilePath dau数据文件路径，dau文件时从Hive表查询出来后带出来的默认格式文件	#
# 																		#
################################### 获取DAU数据 ##########################

class GetDAUData

	def self.getDAUDataFromFile (filePath)
		dataArray = Array.new

		if !filePath || !File.exist?(filePath) then
			puts "DAU数据文件不存在".red
			return dataArray
		end

		dauLog = File.open(filePath).read
		dataArray = dauLog.split("\n")
		if dataArray.count > 0 then
			dataArray.delete_at(0)
		end

		return dataArray
	end

end
