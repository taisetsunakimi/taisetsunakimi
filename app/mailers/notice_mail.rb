class NoticeMail < ActionMailer::Base
  default from: "root@taisetsunakimi.net",
          to: "guangchuan.h@gmail.com"

  def sendmail(title, body)
    mail(subject: title, body: body)
  end
end
