class NursequestionMailer < ActionMailer::Base
  default from: "scad@scad.taisetsunakimi.net",
            to: "thiroma@wf7.so-net.ne.jp"
  def nursequestionmail(question)
    @question = question
    title = "保健師・助産師から質問を受け付けました。"
    mail(subject: title, template_path: 'nursequestionmail_mailer', template_name: 'nursquestionmail.text.erb')
  end
end
