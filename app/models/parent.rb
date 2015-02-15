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

  def fetus_week_choice
    [["22週",22],["23週",23],["24週",24],["25週",25],
    ["26週",26],["27週",27],["28週",28],["29週",29],["30週",30],
    ["31週",31],["32週",32],["33週",33],["34週",34],["35週",35],
    ["36週",36],["37週",37],["38週",38],["39週",39],["40週",40],
    ["41週",41],["42週",42]]

  end

  def fetus_day_choice
    [["0日",0],["1日",1],["2日",2],["3日",3],["4日",4],["5日",5],["6日",6]]
  end

  VALID_TEL_REGEX = /\d{2,4}-\d{2,4}-\d{4}/
  validates :mailaddr, presence: true, length: { maximum: 50 }, uniqueness: { scope: :birthday }
  validates :birthday, presence: true
  validates :fetus_week, presence: true
  validates :fetus_day, presence: true
  validates :tel_no, format: { with: VALID_TEL_REGEX }, allow_blank: true
  validates :birthweight, numericality: { only_integer: true }, allow_blank: true
end
