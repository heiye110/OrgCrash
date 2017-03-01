#!/usr/bin/ruby
require_relative 'AllVersionCrashRate.rb'
require_relative 'SingleVersionCrashDetail.rb'

############################## Crash统计总入口 ###########################
# 																		#
# 主要统计两块数据：														#
# 1.所有版本及单个版本的Crash量、Crash占比、Crash率、DAU占比 					#
# 2.指定版本某天的Crash详情												#
# 																		#
# 调用该脚本需要传进来一个参数:  											#
# dauFilePath dau数据文件路径，dau文件时从Hive表查询出来后带出来的默认格式文件	#
# 																		#
#########################################################################

def getCurrentTime 
	return "#{Time.new.strftime("%Y-%m-%d")}"
end

# dau数据文件路径
dauFilePath = ARGV[0]




# 统计各个版本Crash率时，所有版本数组
allVersionArray = ["9.1.6",
				   "9.1.2",
				   "9.1.0",
				   "9.0.8",
				   "9.0.6",
				   "9.0.2",
				   "9.0.1",
				   "9.0.0",
				   "8.1.6"
				   ];

# 统计的时间段，起始时间、结束时间（如果只分析一天的，就把起始时间和结束日期设置成同一天即可）
analyseStartDate = "2017-02-16"
analyseEndDate = "2017-02-25"

# 分析所有版本以及各版本的Crash量、Crash占比、Crash率、DAU占比
AllVersionCrashRate.statrAnalyseCrashRate(allVersionArray, analyseStartDate, analyseEndDate, dauFilePath)





# 统计单个版本某天Crash详情时，单个版本号
signalVersion = "9.1.6"

# 统计单个版本某天Crash详情时，具体某一天
signalDate = "2017-02-25"

# 生成的单个版本某一个天Crash详情文件路径
createFilePath = "/Users/lmc/Desktop/Crash/发新版后Crash分析报告/#{signalVersion}_#{signalDate}_crash_detail.log"

# 分析某个版本某一天的Crash详细信息
SingleVersionCrashDetail.analyseSingleVersionCrash(signalDate, signalVersion, createFilePath)

