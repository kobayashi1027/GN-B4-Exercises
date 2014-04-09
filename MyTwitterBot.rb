# -*- coding: utf-8 -*-
require './TwitterBot.rb' # TwitterBot.rbの読み込み

#---------- MyTwitterBot ----------                                                                         
class MyTwitterBot < TwitterBot
  # 機能を追加
  def test
    #tweet("TwitterBotのテストです．")
    gettest = get_tweet
    #p gettest[3]["user_id"]
    #p gettest[3]["user_name"]
    #p gettest[3]["message"]
    #p gettest[3]["time"]
    i = 0
    while i < 20
      p gettest[i]["message"]
      i += 1
    end
  end
end

#「．．．」と言って の試作
#str = gettest[3]["message"]
#check = str.include?("と言って")
#if check
#  lpos = str.index("「")
#  rpos = str.rindex("」と言って")
#  
#  print(str[lpos+1..rpos-1])
#
#else
#  print("error\n")
#end

classtest = MyTwitterBot.new
classtest.test
