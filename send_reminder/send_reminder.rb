#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
require 'mongo'
require 'rubygems'
require 'date'
require 'time'
require 'mail'
require 'net/smtp'
require 'nkf'
require 'mail-iso-2022-jp'

# DB接続
con = Mongo::Connection.new
parents_db = con.db('niibe_development')
notice_config_db = con.db('scad_development')
coll_parents = parents_db["parents"]
coll_notice_config = notice_config_db["notice_configs"]

# 通知タイミング/月
$notice_config = 1
### 本日UTC
$today = Time.now.utc.to_date
# メールfrom
$from = "root@taisetsunakimi.net"
# 健診予定日の計算
def set_medical_day(birthday, fetus_week, fetus_day)
    age3 = Date.parse(birthday.to_s) >> 36
    # 3歳未満
    if $today > age3
        #通知日は、出産予定日＋健診日-通知タイミング
        yoteibi = Date.parse(birthday.to_s) + ((40 - fetus_week) * 7 + fetus_day )
	$m0_5 = yoteibi + 6 - $notice_config
        $m1_5 = yoteibi + 18 - $notice_config
    # 3歳以上
    else
        # 通知日は、誕生日＋健診日-通知タイミング
        $m3 = Date.parse(birthday.to_s) >> (12 * 3 - $notice_config)
        $m5_5 = Date.parse(birthday.to_s) >> (12 * 5.5 - $notice_config)
        $m9 = Date.parse(birthday.to_s) >> (12 * 9 - $notice_config)
        $m13 = Date.parse(birthday.to_s) >> (12 * 13 - $notice_config)
        $m16 = Date.parse(birthday.to_s) >> (12 * 16 - $notice_config)
    end
end

# リマインダー送信
def send_mail(ntype)
    # メールテンプレート取得
    con = Mongo::Connection.new
    notice_config_db = con.db('scad_development')
    coll_notice_config = notice_config_db["notice_configs"]
    coll_notice_config.find({"medical_type" => "#{ntype}"}).each{ |row|
    $title = row["mail_subject"]
    $body = row["mail_body"]
    }
    sendmail($from, $mail_to, $title, $body)

end

def sendmail(from, to, subject, body)
smtp_settings = {:address => "localhost",
                  :port => 25,
                  :domain => "taisetsunakimi.net"}

Mail.defaults do
  delivery_method :smtp, smtp_settings
end

mail = Mail.new
mail.charset = 'ISO-2022-JP'
mail.from = "#{from}"
mail.to = "#{to}"
mail.subject = NKF.nkf('-Mj', subject)
#mail.add_file 'images/rails.png'
mail.body = "#{body}"
#(mail.parts - mail.attachments)[0].charset = 'ISO-2022-JP'
mail.deliver

end

# リマインダー対象取得
coll_parents.find.each{ |doc|
    $mail_to = doc["mailaddr"]
    birthday = doc["birthday"]
    fetus_week = doc["fetus_week"]
    fetus_day = doc["fetus_day"]
    remember_input = doc["remember_input"]
p "=== 1 ==="
p "remember_input => #{remember_input}"



    # リマインダー設定している場合のみ
    if remember_input
        # 健診予定日の設定
        set_medical_day(birthday, fetus_week, fetus_day)
    
        case $today 
        when $m0_5
	    send_mail("修正6ヶ月")
        when $m1_5
	    send_mail("修正1歳半")
        when $m3
	    send_mail("3歳")
        when $m5_5
	    send_mail("5歳半")
        when $m9
	    send_mail("9歳")
        when $m13
	    send_mail("13歳")
        when $m16
	    send_mail("16歳")
        end
    end

}

