class Championship
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  field :current_round_id
  has_many :rounds, autosave: true, inverse_of: :championship
  has_many :leagues, autosave: true

  validates :name, presence: true, uniqueness: true
  default_scope -> { asc(:name) }

  def current_round
    rounds.find(current_round_id)
  end

  def as_json(options={})
    attrs = super(only: [:name])
    attrs.merge!({ id: _id.to_s })

    attrs.merge!({
      id: _id.to_s,
      current_round: current_round_id.to_s,
      rounds: rounds
    }) if options[:include_rounds]

    attrs
  end

end
