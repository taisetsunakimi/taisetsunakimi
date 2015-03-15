class NursequestionMailer < ActionMailer::Base
  default from: "root@taisetsunakimi.net",
            to: "guangchuan.h@gmail.com"
  def nursequestionmail(question)
    @question = question
    title = "保健師・看護師から質問を受け付けました。"
    mail(subject: title, template_path: 'nursequestionmail_mailer', template_name: 'nursquestionmail.text.erb')
  end
end
