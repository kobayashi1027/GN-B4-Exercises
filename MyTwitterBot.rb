# -*- coding: utf-8 -*-
require './TwitterBot.rb'     # TwitterBot.rbの読み込み
require 'rexml/document'      # XMLファイル処理用
require 'open-uri'            # httpのURLを普通のファイルのように扱うため
require 'date'                # 日付の取得
require 'google/api_client'   # googleAPI用
require 'yaml'
require 'time'


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
    
    if !(output.empty?)
      print(output)
      #tweet(output)
    end
    
  end

  
  #
  # カレンダー情報の取得
  #
  def calender

    # Initialize OAuth 2.0 client
    # authorization
    oauth_yaml = YAML.load_file('google-api.yaml')
    client = Google::APIClient.new
    client.authorization.client_id = oauth_yaml["client_id"]
    client.authorization.client_secret = oauth_yaml["client_secret"]
    client.authorization.scope = oauth_yaml["scope"]
    client.authorization.refresh_token = oauth_yaml["refresh_token"]
    client.authorization.access_token = oauth_yaml["access_token"]
    
    # access_tokenの再取得
    # ※client.authorization.expired? が常にfalseを返すので意味がない？
    #if client.authorization.refresh_token && client.authorization.expired?
    #  client.authorization.fetch_access_token!
    #end
    client.authorization.fetch_access_token!

    cal = client.discovered_api('calendar', 'v3')

    # 年月日の取得
    d = Date.today
    year = (d+3).year
    month = (d+3).month
    day = (d+3).day
    print("3日後は", year, "-", month, "-", day, "\n")
    
    # 時間を格納
    time_min = Time.utc(year, month, day, 0).iso8601
    time_max = Time.utc(year, month, day, 23, 59).iso8601

    # イベントの取得
    # calenderIdでカレンダーを指定（自分のはprimary）
    params = {'calendarId' => 'swlabgn@gmail.com',
      'orderBy' => 'startTime',
      'timeMax' => time_max,
      'timeMin' => time_min,
      'singleEvents' => 'True'}
    
    result = client.execute(:api_method => cal.events.list,
                            :parameters => params)

    # イベントの格納
    events = []
    result.data.items.each do |item|
      events << item
    end

    # 予定があれば出力
    if !(events.empty?)
      events.each do |event|
        #printf("%s,%s\n",event.start.dateTime,event.summary)
        print(event.start.dateTime, event.summary, "\n")
        tweet("GNグループの皆様，\n" + 
              "3日後に" + event.summary + "があります．\n" + 
              "お忘れなく．\n" + "小林Botがお伝えしました．")
      end
    end
    
  end



end


bottest = MyTwitterBot.new
#bottest.timeline_tweet
#bottest.whether_tweet
bottest.calender


# 参考文献
# http://blogaomu.com/2012/09/16/ruby-script-using-google-calendar-api
# http://alice345.hatenablog.com/entry/2013/07/26/180900
# http://doruby.kbmj.com/trinityt_on_rails/20081022/Ruby_Google_
# http://qiita.com/iron-breaker/items/2440c4ab41a482b1b096
