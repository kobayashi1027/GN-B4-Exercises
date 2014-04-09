# -*- coding: utf-8 -*-
require './TwitterBot.rb' # TwitterBot.rbの読み込み

#---------- MyTwitterBot ----------                                                                         
class MyTwitterBot < TwitterBot
  # 機能を追加
end

tweettest = MyTwitterBot.new
#tweettest.tweet("TwitterBotのテストです．")

gettest = tweettest.get_tweet
p gettest[2]["user_id"]
p gettest[2]["user_name"]
p gettest[2]["message"]
p gettest[2]["time"]
