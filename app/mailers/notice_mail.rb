class NoticeMail < ActionMailer::Base
  default from: "scad@scad.taisetsunakimi.net",
          to: "thiroma@wf7.so-net.ne.jp"

  def sendmail(title, body)
    mail(subject: title, body: body)
  end
end
