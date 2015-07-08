class Battle
  include Mongoid::Document

  belongs_to :league, inverse_of: nil
  belongs_to :round, inverse_of: nil
  belongs_to :host, class_name: "User", inverse_of: nil
  belongs_to :guest, class_name: "User", inverse_of: nil

  validates :league, :round, :host, :guest, presence: true

  def host_score
    @host_score ||= round.bet_for(user: host).right_answers
  end

  def guest_score
    @guest_score ||= round.bet_for(user: guest).right_answers
  end

  def result
    if host_score == guest_score
      :draw
    elsif host_score > guest_score
      :host_wins
    else
      :guest_wins
    end
  end

  def opponent_of(user: nil)
    if user == host
      guest
    elsif user == guest
      host
    else
      nil
    end
  end
end
