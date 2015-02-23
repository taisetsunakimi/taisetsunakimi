class ParentsMailer < ActionMailer::Base
  default from: "root@taisetsunakimi.net"

  def parentsmail(parm, question)
    @parm = parm
    to = @parm[:mailaddr]
logger.debug("----------------------------------------------")
logger.debug(@parm[:birthday])
logger.debug("----------------------------------------------")


    if question
      @question = question
      title = "質問を受け付けました。"
      mail(to: to, subject: title, template_path: 'parents_mailer', template_name: 'parentquestionsmail.text.erb')
    else
      title = "健診のお知らせへの登録ありがとうございました。"
      mail(to: to, subject: title, template_path: 'parents_mailer', template_name: 'parentsmail.text.erb')
    end 
  end
end
