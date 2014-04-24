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

  #
  # messageをtwitterにツイートする．
  # ./TwitterBot.rb のtweetメソッドのオーバライドである．
  # botからのつぶやきとわかるように，メッセージの末尾に" by bot"をつける
  # ツイートが(" by bot"込みで)140文字を超える場合，エラーメッセージを
  # 標準出力に出力する．
  #
  def tweet(message)
    if message.length > (140 - " by bot".length)
      print(<<STRING
ERROR: Message is longer than 140 characters.
       Couldn't tweet.
STRING
            )
    else
      super(message + " by bot")
    end
  end


  #
  # タイムラインを受信し，"「xxx」と言って"という文章を含むツイートがある場合，
  # "xxx"とツイートする．
  # "「」"内が空の場合はツイートしない
  #
  def timeline_tweet                          # メソッド名の再考を．．．
    timeline = get_tweet

    timeline.each do |var|
      if /「(.+)」と言って/ =~ var["message"]
        tweet($1)
        #puts $1
      end
    end

  end


  #
  # プログラム起動日とその翌日の岡山県南部の天気をツイートする．
  #
  def weather_tweet

    # 年月日の取得
    d = Date.today
    today = d.strftime("%Y/%m/%d")
    tomorrow = (d+1).strftime("%Y/%m/%d")

    output = ""

    # XMLファイルを開き，天気を取り出す
    begin
      f = open("http://www.drk7.jp/weather/xml/33.xml")
      #f = `curl http://www.drk7.jp/weather/xml/33.xml`
      doc = REXML::Document.new(f)
      
      doc.elements.each('weatherforecast/pref/area[2]/info') do |element|
        date =  element.attributes["date"]
        weather = element.elements['weather'].text

        if date == today
          output += "今日の天気は" + weather + "でしょう．\n"
        elsif date == tomorrow
          output += "明日の天気は" + weather + "でしょう．"
        end

      end

    rescue
      # xmlファイルを開けなかった時のエラー処理
      print("ERROR: Couldn't get weather forecast.\n")
    end
    
    # 天気が取得できていればツイート
    if !(output.empty?)
      #print(output)
      tweet(output)
    end
    
  end

  
  #
  # 3日後のGNグループの予定をツイート
  #
  def schedule_tweet

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
    # ※client.authorization.expired? が常にfalseを返してる？
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
    #print("3日後は", year, "-", month, "-", day, "\n")
    
    # 時間を格納
    time_min = Time.utc(year, month, day, 0).iso8601
    time_max = Time.utc(year, month, day, 23, 59).iso8601

    # イベントの取得
    # calendarIdでカレンダを指定（自分のはprimary）
    calender_yaml = YAML.load_file('calendarId.yaml')
    params = {'calendarId' => calender_yaml["calendarId"],
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
        #print(event.start.dateTime, event.summary, "\n")
        output = "GNグループの皆様，\n" + 
          "3日後に" + event.summary + "があります．\n" + "お忘れなく．"
        tweet(output)
      end
    else
      print("No entry.\n")
    end
    
  end



end


bottweet = MyTwitterBot.new
bottweet.timeline_tweet
bottweet.weather_tweet
bottweet.schedule_tweet
