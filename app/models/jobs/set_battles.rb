class Jobs::SetBattles
  extend Resque::Plugins::LockTimeout
  extend Resque::Plugins::Retry

  @loner = true
  @lock_timeout = 120
  @retry_limit = 12
  @retry_delay = 5

  @queue = :rounds

  def self.perform(round_id)
    round = Round.find(round_id)
    round.championship.leagues.each do |league|
      league.battles_for(round: round)
    end
  end
end
