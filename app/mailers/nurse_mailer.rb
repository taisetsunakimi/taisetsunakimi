class NurseMailer < ActionMailer::Base
  default from: "root@taisetsunakimi.net"

  def nuresmail(question)
    @question = question
    to = @question[:mailaddr]
    title = "質問を受け付けました。"
    mail(to: to, subject: title, template_path: 'nurse_mailer', template_name: 'nuresmail.text.erb')
  end
end
