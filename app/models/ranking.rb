class Ranking
  include Mongoid::Document

  field :placements, type: Array, default: []

  belongs_to :league, inverse_of: nil
  belongs_to :round, inverse_of: nil

  def as_json(options={})
    attrs = super(only: [:placements])
    attrs.merge!({
      league: league.id.to_s,
      round: round.id.to_s
    })
    attrs
  end
end
