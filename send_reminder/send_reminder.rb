#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
require 'mongo'
require 'rubygems'
require 'date'
require 'time'
require 'mail'
require 'nkf'
require 'mail-iso-2022-jp'
require 'logger'

# parents DB接続
$con = Mongo::Connection.new
parents_db = $con.db('niibe_development')
coll_parents = parents_db["parents"]

# 通知タイミング/月
$notice_config = 1
### 本日UTC
$today = Time.now.utc.to_date
# メールfrom
$from = "root@taisetsunakimi.net"
$return_path = "guangchuan.h@gmail.com"
# ログ出力
$log = Logger.new("./log/senmail.log", 50, 10*1024*1024)


# 健診予定日の計算
def set_medical_day(birthday, fetus_week, fetus_day)
    $m0_5, $m1_5, $m3, $m5_5, $m9, $m13, $m16 = nil
    age3 = Date.parse(birthday.to_s) >> 36
    $log.info {"MESSAGE 3歳になる日は[#{age3}]です。"}
    # 3歳未満
    if $today > age3
        #通知日は、出産予定日＋健診日-通知タイミング
        yoteibi = Date.parse(birthday.to_s) + ((40 - fetus_week) * 7 + fetus_day )
        $m0_5 = yoteibi + 6 - $notice_config
        $m1_5 = yoteibi + 18 - $notice_config
        $log.info ("MESSAGE 3歳未満[誕生日 =>#{Date.parse(birthday.to_s)}] [出産予定日 =>#{yoteibi}]")
    # 3歳以上
    else
        # 通知日は、誕生日＋健診日-通知タイミング
        $m3 = Date.parse(birthday.to_s) >> (12 * 3 - $notice_config)
        $m5_5 = Date.parse(birthday.to_s) >> (12 * 5.5 - $notice_config)
        $m9 = Date.parse(birthday.to_s) >> (12 * 9 - $notice_config)
        $m13 = Date.parse(birthday.to_s) >> (12 * 13 - $notice_config)
        $m16 = Date.parse(birthday.to_s) >> (12 * 16 - $notice_config)
        $log.info ("MESSAGE 3歳以上[誕生日 =>#{Date.parse(birthday.to_s)}]")
    end
end

# リマインダー用テンプレート取得
def send_mail(ntype)
    $log.info ("MESSAGE DB接続、メールテンプレート取得開始")
  begin
    # メールテンプレート取得
    notice_config_db = $con.db('scad_development')
    coll_notice_config = notice_config_db["notice_configs"]
    coll_notice_config.find({"medical_type" => "#{ntype}"}).each{ |row|
    $title = row["mail_subject"]
    $body = row["mail_body"]
    }
  rescue => err
    $log.fatal("ERROR DBからテンプレート取得時例外が発生")
    $log.fatal(err)
  end
    # 引数チェック
    $log.info ("MESSAGE DB接続、メールテンプレート取得完了")
  
    # mail呼び出し
    smail($from, $mail_to, $title, $body, "#{ntype}")
  
end

# リマインダー送信
def smail(from, to, subject, body, ntype)
    $log.info ("MESSAGE メール環境設定")
  begin
    domain = "taisetsunakimi.net"
    smtp_settings = {:address => "localhost",
                     :port => 25,
                     :domain => "#{domain}"}

    Mail.defaults do
        delivery_method :smtp, smtp_settings
    end

    $log.info ("MESSAGE メール組み立て開始")
    mail = Mail.new do
	from "#{from}"
	to "#{to}"
        subject NKF.nkf('-Mj', subject)
        body "#{body}"
    end
    mail.charset = 'ISO-2022-JP'
    mail["Return-Path"] = "#{$return_path}"
    #mail.add_file 'images/rails.png'
    #(mail.parts - mail.attachments)[0].charset = 'ISO-2022-JP'
    $log.info ("MESSAGE メール送信")
    mail.deliver

    # 送信履歴の作成
    $log.info ("MESSAGE 配信履歴関数呼び出し")
    insert_mail_history("#{to}", "#{subject}", "#{body}", "#{ntype}")
  rescue => err
    $log.fatal ("ERROR メール送信時例外が発生")
    $log.fatal (err)
  end
end

# 送信履歴テーブル作成
def insert_mail_history(to, subject, body, ntype)
    $log.info ("MESSAGE 配信履歴DB接続")
  begin
    mail_history_db = $con.db('scad_development')
    coll_mail_history_db = mail_history_db["mail_history"]
    # ドキュメント作成
    time = Time.new
    doc = {'date' => "#{time}", 'mailaddr' => "#{to}", 'notice_config' => "#{ntype}", 'subject' => "#{subject}", 'body' => "#{body}", 'bounce_info' => "0"}

    $log.info ("MESSAGE 配信履歴DB書込み")
    coll_mail_history_db.insert(doc)

  rescue => err
    $log.fatal ("ERROR 配信履歴作成時例外が発生")
    $log.fatal (err)
  end
end

$log.info ("MESSAGE =============== 処理開始します。===============")
# レコード取得
coll_parents.find.each{ |doc|
    $mail_to = doc["mailaddr"]
    birthday = doc["birthday"]
    fetus_week = doc["fetus_week"]
    fetus_day = doc["fetus_day"]
    remember_input = doc["remember_input"]
    $log.info ("MESSAGE =============== START ===============")
    $log.info {"PARAM [メールアドレス =>#{$mail_to}] [誕生日 =>#{birthday}] [在胎週数 =>#{fetus_week}] [在胎日数 =>#{fetus_day}] [リマインダーチェック =>#{remember_input}]"}

    # リマインダー設定している場合のみ
    if remember_input
        # 健診予定日の設定
        set_medical_day(birthday, fetus_week, fetus_day)
        $log.info ("PARAM [修正6ヶ月健診予定日 =>#{$m0_5}] [修正1歳半歳健診予定日 =>#{$m1_5}] [3歳健診予定日 =>#{$m3}] [5歳半健診予定日 =>#{$m5_5}] [9歳健診予定日 =>#{$m9}] [13歳健診予定日 =>#{$m13}] [16歳健診予定日 =>#{$m16}]=========")
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
        else
            $log.info ("MESSAGE 通知対象外です。")
        end
    end
    $log.info ("MESSAGE =============== END ===============")
}

