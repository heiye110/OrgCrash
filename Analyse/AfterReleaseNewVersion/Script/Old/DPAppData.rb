#!/usr/bin/ruby
require 'json'
require 'net/http'
require 'time'
require 'colored'
require 'base64'
require 'openssl'

class DPAppData

	# 该接口的wiki文档：http://wiki.sankuai.com/pages/viewpage.action?pageId=683534884

	def self.getUV(startDate,endDate,platform,appVersion)

		uvDataArray = Array.new

		uri = "/analytics/metrics/uv"
		gmtTime = Time.now.httpdate
		secretID = "pingtai_sh_ios"
		secretKey = "871df02ecf01012e53bd1941e22b23ca"
		string_to_sign = "GET" + " " + "#{uri}" + "\n" + "#{gmtTime}"
		signature = Base64.strict_encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), secretKey, string_to_sign))
		authorization = "MWS" + " " + "#{secretID}" + ":" + "#{signature}"

		if appVersion.length == 0 then
			url = URI.parse("http://api.dp.sankuai.com#{uri}?beginDate=#{startDate}&endDate=#{endDate}&app=dianping_nova&os=#{platform}")
		else
			url = URI.parse("http://api.dp.sankuai.com#{uri}?beginDate=#{startDate}&endDate=#{endDate}&app=dianping_nova&os=#{platform}&version=#{appVersion}")
		end
		
		req = Net::HTTP::Get.new(url)
		req['Date'] = gmtTime
		req['Authorization'] = authorization
		req['Content-Type'] = 'application/json;charset=utf-8'
		response = Net::HTTP.new(url.host, url.port).start do |http|
  			http.request(req)
		end

		# puts response.code
		# puts response.content_length
		# puts response.message
		puts response.body

		# 服务端正常返回的数据格式
		#{"data":{"itemCount":2,"items":[{"date":"2016-12-07","app":"dianping_nova","os":"ios","uv":"5808169"},{"date":"2016-12-08","app":"dianping_nova","os":"ios","uv":"5745386"}]}}

		resonseHash = JSON.parse(response.body)
		# puts resonseHash
		dataHash = resonseHash["data"]
		if dataHash && dataHash.include?("items") then
			uvDataArray = dataHash["items"]
		end

		return uvDataArray

	end

	def self.getDAUFromHive (dauFilePath)
		dauArray = Array.new

		if !dauFilePath || !File.exist?(dauFilePath) then
			puts "DAU数据文件不存在".red
			return dauArray
		end

		dauLog = File.open(dauFilePath).read
		dauArray = dauLog.split("\n")

		return dauArray
	end

end
