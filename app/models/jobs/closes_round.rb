class Jobs::ClosesRound
  extend Resque::Plugins::LockTimeout
  extend Resque::Plugins::Retry

  @loner = true
  @lock_timeout = 120
  @retry_limit = 12
  @retry_delay = 5

  @queue = :rounds

  def self.perform(round_id)
    Round.find(round_id).update_attributes(opened_for_bets: false)
  end
end
