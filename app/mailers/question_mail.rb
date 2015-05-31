class QuestionMail < ActionMailer::Base
  default from: "scad@scad.taisetsunakimi.net",
     to: "thiroma@wf7.so-net.ne.jp"

  def sendquestion(parm, question)
    @parm = parm
    @question = question
     title = "健診リマインダーシステムから質問がありました。"
     reply_to = @parm[:mailaddr]

     mail(subject: title, reply_to: reply_to, template_path: 'question_mail', template_name: 'sendquestion.text.erb')
  end
end
