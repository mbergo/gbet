class BetMatch
  include Mongoid::Document

  field :host_score, type: Integer, default: 0
  field :guest_score, type: Integer, default: 0

  belongs_to :match, class_name: "Match", inverse_of: nil

  embedded_in :bet, :inverse_of => :bet_matches

  def result
    if host_score == guest_score
      :draw
    elsif host_score > guest_score
      :host_wins
    else
      :guest_wins
    end
  end

  def as_json(options={})
    attrs = super(only: [:host_score, :guest_score])
    attrs.merge!(match: match.id.to_s)
    attrs
  end
end
