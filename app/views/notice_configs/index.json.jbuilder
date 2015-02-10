json.array!(@notice_configs) do |notice_config|
  json.extract! notice_config, :id, :medical_type, :notice_config, :mail_subject, :mail_body
  json.url notice_config_url(notice_config, format: :json)
end
