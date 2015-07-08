require 'spec_helper'

describe Bet do
  let(:round) { Fabricate(:championship).rounds.first }
  let(:match) { round.matches.first }
  let(:another_match) { round.matches.second }
  let(:user) { Fabricate(:user) }

  describe "set a bet for a match" do
    describe "when the round is opened for bets" do
      before { round.update_attributes(:opened_for_bets => true) }

      it "should save the bet" do
        expect(user.set_bet_for(match, 2, 5)).to eq(true)

        bet = round.bet_for(user: user)
        expect(bet.bet_matches.to_a.count).to eq(1)

        bet_match = bet.bet_matches.first
        expect(bet_match.host_score).to eq(2)
        expect(bet_match.guest_score).to eq(5)
      end

      describe "and has a previous bet for the match" do
        before { user.set_bet_for(match, 2, 5) }

        it "should update the bet" do
          expect(user.set_bet_for(match, 6, 3)).to eq(true)

          bet = round.bet_for(user: user)
          expect(bet.bet_matches.to_a.count).to eq(1)

          bet_match = bet.bet_matches.first
          expect(bet_match.host_score).to eq(6)
          expect(bet_match.guest_score).to eq(3)
        end
      end
    end

    describe "when the round is closed for bets" do

      describe "and was never open" do
        before { round.update_attributes(:opened_for_bets => false) }

        it "should not create a bet" do
          expect(user.set_bet_for(match, 2, 5)).to eq(false)
          expect(Bet.where(:user => user, :round => round)).to be_empty
        end
      end

      describe "and was open before" do
        before do
          user.set_bet_for(match, 2, 5)
          round.update_attributes(:opened_for_bets => false)
        end

        it "should not update the bet" do
          expect(user.set_bet_for(match, 6, 3)).to eq(false)

          bet = round.bet_for(user: user)
          expect(bet.bet_matches.to_a.count).to eq(1)

          bet_match = bet.bet_matches.first
          expect(bet_match.host_score).to eq(2)
          expect(bet_match.guest_score).to eq(5)
        end

        it "should not create bet for another match" do
          expect(user.set_bet_for(another_match, 6, 3)).to eq(false)

          bet = round.bet_for(user: user)
          expect(bet.bet_matches.to_a.count).to eq(1)

          bet_match = bet.bet_matches.first
          expect(bet_match.match).not_to eq(another_match)
          expect(bet_match.match).to eq(match)
        end
      end
    end
  end

  describe "calculate the number of points on the round" do
    describe "when the user do not bet" do
      it "should count as the user bet on draw for all games" do
        bet = round.bet_for(user: user)
        expect(bet.right_answers).to eq(2)
      end
    end

    describe "when the user bet" do
      it "should count one goal to each right result" do
        user.set_bet_for(match, 1, 0)
        bet = round.bet_for(user: user)
        expect(bet.right_answers).to eq(3)
      end
    end
  end
end
