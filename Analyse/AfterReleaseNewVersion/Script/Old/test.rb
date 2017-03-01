#!/usr/bin/ruby
require 'json'
require 'time'

# str = "[UIApplicationDidBecomeActiveNotification]"

# if (str.include? "(") && (str.include? ")") then
# 	puts "fdfsdafadsfasdf"
# else
# 	puts "111111111111111"
# end


startDate = "2016-02-27"
endDate = "2016-02-27"

day = Time.parse(endDate) - Time.parse(startDate)

puts day
puts day/86400




# str = "14 DPScope -[NSNotificationCenter(Debug) nvPostNotificationName:object:userInfo:] (in DPScope) (NSNotificationCenter+Debug.m:111)"

# puts "#{!str.include?("NSNotificationCenter(Debug)")}"