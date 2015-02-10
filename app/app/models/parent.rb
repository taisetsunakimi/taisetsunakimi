class Parent
  include Mongoid::Document
  include Mongoid::Timestamps
  field :mailaddr, type: String
  field :apple_no, type: String
  field :tel_no, type: String
  field :birthday, type: Date
  field :fetus_week, type: Integer
  field :fetus_day, type: Integer
  field :birthweight, type: Integer
  field :notice_flg, type: Mongoid::Boolean
  field :remember_input, type: Mongoid::Boolean

  VALID_TEL_REGEX = /\d{2,4}-\d{2,4}-\d{4}/
  validates :mailaddr, presence: true, length: { maximum: 50 }
  validates :birthday, presence: true
  validates :fetus_week, presence: true
  validates :fetus_day, presence: true
  validates :tel_no, format: { with: VALID_TEL_REGEX } 
  validates :birthweight, numericality: { only_integer: true }
end
