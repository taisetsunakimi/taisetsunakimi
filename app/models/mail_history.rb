class MailHistory
  include Mongoid::Document
  field :date, type: String
  field :notice_config, type: String
  field :mailaddr, type: String
  field :subject, type: String
  field :body, type: String
  field :bounce_info, type: String
  paginates_per 10
end
