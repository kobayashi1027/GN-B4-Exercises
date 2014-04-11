# -*- coding: utf-8 -*-
require './TwitterBot.rb' # TwitterBot.rbの読み込み
require 'rexml/document'  # XMLファイル処理用
require 'open-uri'        # httpのURLを普通のファイルのように扱うため
require "date"            # 日付の取得

#---------- MyTwitterBot ----------                                                                         
class MyTwitterBot < TwitterBot
  # 機能を追加

  #
  # "「xxx」と言って"という文章を含むツイートがタイムライン上にある場合，
  # "xxx"とツイートする．
  #
  def timeline_tweet                          # メソッド名をもうちょっと．．．
    timeline = get_tweet

    timeline.each do |var|
      if /「(.+)」と言って/ =~ var["message"]   # "「xxx」と言って"があれば
        tweet($1)                             # "xxx"とツイート
        #puts $1
      end
    end

  end


  #
  # 今日と明日の岡山県南部の天気をツイートする．
  # 4/11追記...このままでは，以前の天気予報と全く同じ内容の場合，ツイートされない？
  # その日の日付等ユニークな情報も加える必要がある．
  #
  def whether_tweet
    #a = `curl http://www.drk7.jp/weather/xml/33.xml`

    # 年月日の取得
    d = Date.today
    today = d.strftime("%Y/%m/%d")
    tomorrow = (d+1).strftime("%Y/%m/%d")

    output = ""

    open("http://www.drk7.jp/weather/xml/33.xml") {|f|
      doc = REXML::Document.new(f)
      
      doc.elements.each('weatherforecast/pref/area[2]/info') do |element|
        date =  element.attributes["date"]
        weather = element.elements['weather'].text

        if date == today
          output += "今日の天気は" + weather + "でしょう．\n"
        elsif date == tomorrow
          output += "明日の天気は" + weather + "でしょう．\n"
        end

      end
      
    }
    
    if output != ""
      print(output)
      #tweet(output)
    end
    
  end

  
  #
  # 何しようか
  #
  



end


bottest = MyTwitterBot.new
#bottest.timeline_tweet
bottest.whether_tweet



# 参考文献
# http://blogaomu.com/2012/09/16/ruby-script-using-google-calendar-api
# http://alice345.hatenablog.com/entry/2013/07/26/180900
# http://doruby.kbmj.com/trinityt_on_rails/20081022/Ruby_Google_
# http://qiita.com/iron-breaker/items/2440c4ab41a482b1b096
