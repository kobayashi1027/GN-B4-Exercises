# -*- coding: utf-8 -*-
require './TwitterBot.rb' # TwitterBot.rbの読み込み
require 'rexml/document'  # XMLファイル処理用
require 'open-uri'        # httpのURLを普通のファイルのように扱うため

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
  # （とりあえず）1週間の岡山県南部の天気をツイートする．
  #
  def whether_tweet
    #a = `curl http://www.drk7.jp/weather/xml/33.xml`
    #puts a

    open("http://www.drk7.jp/weather/xml/33.xml") {|f|
      doc = REXML::Document.new(f)
      #puts doc
      #puts doc.elements['weatherforecast/pref/area[2]/info/weather'].text

      output = ''
      
      doc.elements.each('weatherforecast/pref/area[2]/info') do |element|
        date =  element.attributes["date"]
        weather =  element.elements['weather'].text

        #puts date + " " + weather
        output << date + " " + weather + "\n"

      end
      
      print(output)
      #tweet(output)
    }
    
  end





end


bottest = MyTwitterBot.new
#bottest.timeline_tweet
bottest.whether_tweet
