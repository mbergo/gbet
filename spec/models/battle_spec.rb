require 'spec_helper'

describe Battle do
  let(:match_1) { Fabricate.build(:match, host_score: 2, guest_score: 0) }
  let(:match_2) { Fabricate.build(:match, host_score: 0, guest_score: 1) }
  let(:match_3) { Fabricate.build(:match, host_score: 3, guest_score: 3) }
  let(:round) { Fabricate(:championship, rounds: [Fabricate.build(:round, matches: [match_1, match_2, match_3])]).rounds.first }

  let(:battle) { Fabricate(:battle, round: round) }

  describe "when checking the battle result between host and guest users" do
    before do
      battle.host.set_bet_for(match_1, 1, 0)
      battle.host.set_bet_for(match_2, 0, 2)
      battle.host.set_bet_for(match_3, 4, 4)

      battle.guest.set_bet_for(match_1, 5, 0)
      battle.guest.set_bet_for(match_2, 0, 3)
      battle.guest.set_bet_for(match_3, 1, 1)
    end

    describe "and host user has more right answers" do
      before { battle.guest.set_bet_for(match_1, 0, 0) }

      it "should return host as winner" do
        expect(battle.result).to eq(:host_wins)
      end
    end

    describe "and guest user has more right answers" do
      before { battle.host.set_bet_for(match_2, 0, 0) }

      it "should return guest as winner" do
        expect(battle.result).to eq(:guest_wins)
      end
    end

    describe "and users has the same number of right answers" do
      before do
        battle.host.set_bet_for(match_3, 1, 0)
        battle.guest.set_bet_for(match_3, 0, 1)
      end

      it "should return a draw" do
        expect(battle.result).to eq(:draw)
      end
    end
  end
end
