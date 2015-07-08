class Bet
  include Mongoid::Document

  belongs_to :round, inverse_of: nil
  belongs_to :user, class_name: "User", inverse_of: nil
  embeds_many :bet_matches, class_name: "BetMatch"

  def as_json(options={})
    bet_matches.as_json(options)
  end

  def right_answers
    round.matches.to_a.count do |match|
      bet_matches.find_or_initialize_by(match: match).result == match.result
    end
  end
end
