class Nursequestion
  include Mongoid::Document
  include Mongoid::Timestamps

  field :belong, type: String
  field :name, type: String
  field :mailaddr, type: String
  field :tel_no, type: String
  field :question_txt, type: String
  field :remember_input, type: Mongoid::Boolean

  VALID_TEL_REGEX = /\d{2,4}-\d{2,4}-\d{4}/
  validates :belong, :presence => true
  validates :name, :presence => true
  validates :mailaddr, presence: true, length: { maximum: 50 }
  validates :tel_no, format: { with: VALID_TEL_REGEX }, allow_blank: true
  validates :question_txt, :presence => true

end
