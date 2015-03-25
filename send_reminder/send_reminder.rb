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

# DB接続
$con = Mongo::Connection.new
$mongo = $con.db('mongoid_dev')
# 通知タイミング/月
$notice_config = 1
# 本日UTC
$today = Time.now.utc.to_date
# メールオプション設定（from,bcc,return_path）
require '/var/share/taisetsunakimi/send_reminder/mail_info.rb'
# ログ出力設定
$log = Logger.new("/var/share/taisetsunakimi/send_reminder/log/senmail.log", 50, 10*1024*1024)

### 健診予定日の計算 ###
def set_medical_day(birthday, fetus_week, fetus_day)
    $m0_5, $m1_5, $m3, $m5_5, $m9, $m13, $m16 = nil
    age3 = Date.parse(birthday.to_s) >> 36
#    $log.info {"MESSAGE ----- 3歳になる日は[#{age3}] -----"}
    # 3歳未満
    if ( $today >> $notice_config ) < age3
        #通知日は、出産予定日から計算した健診予定日の一ヵ月前
        yoteibi = Date.parse(birthday.to_s) + ((40 - fetus_week) * 7 + ( 7 - fetus_day) )
        $m0_5 = yoteibi >> ( 6 - $notice_config )
        $m1_5 = yoteibi >> ( 18 - $notice_config )
        $log.info ("MESSAGE 3歳未満[誕生日 =>#{Date.parse(birthday.to_s)}] [出産予定日 =>#{yoteibi}]")
        $log.info ("PARAM ----- 3歳未満 -----
[誕生日                =>#{Date.parse(birthday.to_s)}] [出産予定日 =>#{yoteibi}]
[在胎週数              =>#{fetus_week}] [在胎日数 =>#{fetus_day}]
[修正6ヶ月健診配信日   =>#{$m0_5}]
[修正1歳半歳健診配信日 =>#{$m1_5}]")
    # 3歳以上
    else
        # 通知日は、誕生日から計算した健診予定日の一ヵ月前
        $m3 = Date.parse(birthday.to_s) >> (12 * 3 - $notice_config)
        $m5_5 = Date.parse(birthday.to_s) >> (12 * 5.5 - $notice_config)
        $m9 = Date.parse(birthday.to_s) >> (12 * 9 - $notice_config)
        $m13 = Date.parse(birthday.to_s) >> (12 * 13 - $notice_config)
        $m16 = Date.parse(birthday.to_s) >> (12 * 16 - $notice_config)
        $log.info ("PARAM ----- 3歳以上 -----
[誕生日          =>#{Date.parse(birthday.to_s)}]
[3歳健診配信日   =>#{$m3}]
[5歳半健診配信日 =>#{$m5_5}]
[9歳健診配信日   =>#{$m9}]
[13歳健診配信日  =>#{$m13}]
[16歳健診配信日  =>#{$m16}]")
    end
end

### リマインダー用テンプレート取得 ###
def get_tmpl(ntype)
    $log.info ("MESSAGE ----- 【通知対象】 -----")
    $log.info ("MESSAGE ----- DB接続、メールテンプレート取得 -----")
  begin
    # メールテンプレート取得
    coll_notice_config = $mongo["notice_configs"]
    coll_notice_config.find({"medical_type" => "#{ntype}"}).each{ |row|
    $title = row["mail_subject"]
    body = row["mail_body"]
    # 配信停止機能の追加：メール本文にidを追加
    body.gsub!('<_ID>',"#{$ids}")
    $body = body
    }
  rescue => err
    $log.fatal("ERROR !!!!! DBからテンプレート取得時例外が発生 !!!!!")
    $log.fatal(err)
  end
end

### リマインダー送信 ###
def send_mail()
    $log.info ("MESSAGE ----- メール環境設定 -----")
  begin
    domain = "taisetsunakimi.net"
    smtp_settings = {:address => "localhost",
                     :port => 25,
                     :domain => "#{domain}"}

    Mail.defaults do
        delivery_method :smtp, smtp_settings
    end
    $log.info ("MESSAGE ----- メール送信 -----")
    mail = Mail.new do
	from "#{$from}"
	to "#{$mail_to}"
        bcc $bcc
        subject NKF.nkf('-Mj', "#{$title}")
        body "#{$body}"
    end
    mail.charset = 'ISO-2022-JP'
    mail["Return-Path"] = "#{$return_path}"
    #mail.add_file 'images/rails.png'
    #(mail.parts - mail.attachments)[0].charset = 'ISO-2022-JP'
    mail.deliver

    # 送信履歴の作成
  rescue => err
    $log.fatal ("ERROR !!!!! メール送信時例外が発生 !!!!!")
    $log.fatal (err)
  end
end

### 送信履歴テーブル作成 ###
def insert_mail_history(ntype)
    $log.info ("MESSAGE ----- 配信履歴DBの作成 -----")
    coll_mail_history_db = $mongo["mail_histories"]
    # ドキュメント作成
    time = Time.new
    doc = {'date' => "#{time}", 'mailaddr' => "#{$mail_to}", 'notice_config' => "#{ntype}", 'subject' => "#{$title}", 'body' => "#{$body}", 'bounce_info' => "0"}
    coll_mail_history_db.insert(doc)
end

### main ###
def main()
    $log.info ("MESSAGE =============== [#{$today}]処理開始 ===============")
    # parentsレコード取得
    coll_parents = $mongo["parents"]
    coll_parents.find.each{ |doc|
        $mail_to = doc["mailaddr"]
        birthday = doc["birthday"]
        fetus_week = doc["fetus_week"]
        fetus_day = doc["fetus_day"]
        notice_flg = doc["notice_flg"]
        $ids = doc["_id"]
    
        # リマインダーチェックありの場合
        if notice_flg
        $log.info {"PARAM [メールアドレス:#{$mail_to}] [誕生日:#{birthday}] [在胎週数:#{fetus_week}] [在胎日数:#{fetus_day}] "}
        # 健診予定日の設定
        set_medical_day(birthday, fetus_week, fetus_day)
            # 対象にはメール送信
            case $today 
            when $m0_5
                get_tmpl("修正6ヶ月") | send_mail | insert_mail_history("修正6ヶ月")
            when $m1_5
                get_tmpl("修正1歳半") | send_mail | insert_mail_history("修正1歳半")
            when $m3
                get_tmpl("3歳") | send_mail | insert_mail_history("3歳")
            when $m5_5
                get_tmpl("5歳半") | send_mail | insert_mail_history("5歳半")
            when $m9
                get_tmpl("9歳") | send_mail | insert_mail_history("9歳")
            when $m13
                get_tmpl("13歳") | send_mail | insert_mail_history("13歳")
            when $m16
                get_tmpl("16歳") | send_mail | insert_mail_history("16歳")
            else
                $log.info ("MESSAGE ----- 通知対象外 -----")
            end
        end
    }
    $log.info ("MESSAGE =============== [#{$today}]処理終了 ===============")
end

if __FILE__ == $0
    main
end

