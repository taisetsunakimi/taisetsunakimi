class Question
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :parent
  field :question_txt, type: String
  field :register_reminder, type: Mongoid::Boolean

  def mailaddr
    parent.mailaddr
  end
  def mailaddr=(value)
    parent.mailaddr=value
  end

  def apple_no
    parent.apple_no
  end
  def apple_no=(value)
    parent.apple_no=value
  end

  def tel_no
    parent.tel_no
  end
  def tel_no=(value)
    parent.tel_no=value
  end

  def birthday
    parent.birthday
  end
  def birthday=(value)
    parent.birthday=value
  end

  def fetus_week
    parent.fetus_week
  end
  def fetus_week=(value)
    parent.fetus_week=value
  end

  def fetus_day
    parent.fetus_day
  end
  def fetus_day=(value)
    parent.fetus_day=value
  end

  def birthweight
    parent.birthweight
  end
  def birthweight=(value)
    parent.birthweight=value
  end

  def remember_input
    parent.remember_input
  end
  def remember_input=(value)
    parent.remember_input=value
  end

  validates :question_txt, :presence => true

end
