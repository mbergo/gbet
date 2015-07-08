class Jobs::CalculateRanking
  extend Resque::Plugins::LockTimeout
  extend Resque::Plugins::Retry

  @loner = true
  @lock_timeout = 1.hour.to_i
  @retry_limit = 12
  @retry_delay = 5

  @queue = :rounds

  def self.perform(round_id)
    round = Round.find(round_id)
    if round.championship.leagues.all? { |league| league.members.present? ? league.ranking_for(round: round).present? : true }
      round.update_attributes(processed_at: Time.now)
      next_round = round.championship.rounds.detect{|r| r.order == round.order + 1}
      round.championship.update_attributes(current_round_id: next_round.id.to_s) if next_round.present?
    end
  end
end
