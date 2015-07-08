class Jobs::CheckRoundsToBeClosed
  extend Resque::Plugins::LockTimeout

  @loner = true
  @lock_timeout = 120

  @queue = :checks

  def self.perform
    Championship.all.to_a.each do |championship|
      championship.rounds.where(opened_for_bets: true, :closes_at.ne => nil).each do |round|
        Resque.enqueue_at(round.closes_at, Jobs::ClosesRound, round.id.to_s) if (round.closes_at.advance(:minutes => -10) < Time.now)
        Resque.enqueue_at(round.closes_at.advance(:days => -1), Jobs::SetBattles, round.id.to_s) if (round.closes_at.advance(:days => -1, :minutes => -10) < Time.now)
      end
    end
  end
end
