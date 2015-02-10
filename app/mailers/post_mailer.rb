class PostMailer < ActionMailer::Base
  default from: "root@taisetsunakimi.net"
  default to: "guangchuan.h@gmail.com"

  def post_email(user, post)
    
    mail subject: "title"
  end
end
