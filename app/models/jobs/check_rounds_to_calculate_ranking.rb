class Jobs::CheckRoundsToCalculateRanking
  extend Resque::Plugins::LockTimeout

  @loner = true
  @lock_timeout = 120

  @queue = :checks

  def self.perform
    Championship.all.to_a.each do |championship|
      championship.rounds.where(opened_for_bets: false, processed_at: nil).each do |round|
        Resque.enqueue(Jobs::CalculateRanking, round.id.to_s)
      end
    end
  end
end
