class NoticeConfig
  include Mongoid::Document
  field :medical_type, type: String
  field :notice_config, type: String
  field :mail_subject, type: String
  field :mail_body, type: String
  field :testmail, type: String 
end

