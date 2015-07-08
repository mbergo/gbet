require 'spec_helper'

describe League do
  let(:users) { Fabricate.times(4, :user) }
  let(:championship) { Fabricate(:championship, n_rounds: 4) }
  let(:rounds) { championship.rounds }
  let(:round) { championship.rounds.first }
  let(:league) { Fabricate(:league, members: users, championship: championship) }

  describe "has to form battles with their members" do
    describe "when is the first round" do
      it "should choose members randomly" do
        battles_1 = league.battles_for(round: round)
        expect(battles_1.count).to eq(2)

        expect([
          battles_1.first.host, battles_1.first.guest,
          battles_1.second.host, battles_1.second.guest
        ].uniq.count).to eq(4)
      end
    end

    describe "when is not the first round" do
      it "should not repeat battles until they all faced each other" do
        battles_1 = league.battles_for(round: rounds.first)
        battles_2 = league.battles_for(round: rounds.second)
        battles_3 = league.battles_for(round: rounds.third)

        expect(battles_1.count).to eq(2)
        expect(battles_2.count).to eq(2)
        expect(battles_3.count).to eq(2)

        pairs = [
          [battles_1.first.host, battles_1.first.guest],
          [battles_1.first.guest, battles_1.first.host],
          [battles_1.second.host, battles_1.second.guest],
          [battles_1.second.guest, battles_1.second.host],

          [battles_2.first.host, battles_2.first.guest],
          [battles_2.first.guest, battles_2.first.host],
          [battles_2.second.host, battles_2.second.guest],
          [battles_2.second.guest, battles_2.second.host],

          [battles_3.first.host, battles_3.first.guest],
          [battles_3.first.guest, battles_3.first.host],
          [battles_3.second.host, battles_3.second.guest],
          [battles_3.second.guest, battles_3.second.host]
        ].uniq

        expect(pairs.count).to eq(12)

        battles_4 = league.battles_for(round: rounds[3])

        repeated_pairs = [
          [battles_4.first.host, battles_4.first.guest],
          [battles_4.first.guest, battles_4.first.host],
          [battles_4.second.host, battles_4.second.guest],
          [battles_4.second.guest, battles_4.second.host]
        ].uniq

        expect(repeated_pairs.all?{|p| pairs.include?(p)}).to eq(true)
      end
    end
  end

  describe "has to calculate the ranking" do
    def init_battles_for round
      battles = league.battles_for(round: round)
      round.matches.each do |match|
        battles.each do |battle|
          battle.host.set_bet_for(match, match.host_score, match.guest_score)
          battle.guest.set_bet_for(match, match.host_score, match.guest_score)
        end
      end
    end

    describe "when is the first round" do
      let(:current_round) { round }

      before { init_battles_for current_round }

      it "should return the ranking considering the result on each battle" do
        battles = league.battles_for(round: current_round)
        max_scores = current_round.matches.count
        match = current_round.matches.first

        battles[0].host.set_bet_for(match, match.guest_score, match.host_score)

        current_round.update_attributes(opened_for_bets: false)

        ranking = league.ranking_for(round: current_round)

        expect(ranking.placements[0]).to eq({"id" => battles[0].guest.id, "name" => battles[0].guest.name, "games" => 1, "wins" => 1, "draws" => 0, "loss" => 0, "scores_pro" => max_scores, "scores_against" => max_scores - 1})
        expect(ranking.placements[1]).to eq({"id" => battles[1].guest.id, "name" => battles[1].guest.name, "games" => 1, "wins" => 0, "draws" => 1, "loss" => 0, "scores_pro" => max_scores, "scores_against" => max_scores})
        expect(ranking.placements[2]).to eq({"id" => battles[1].host.id, "name" => battles[1].host.name, "games" => 1, "wins" => 0, "draws" => 1, "loss" => 0, "scores_pro" => max_scores, "scores_against" => max_scores})
        expect(ranking.placements[3]).to eq({"id" => battles[0].host.id, "name" => battles[0].host.name, "games" => 1, "wins" => 0, "draws" => 0, "loss" => 1, "scores_pro" => max_scores - 1, "scores_against" => max_scores})
      end
    end

    describe "when is not the first round" do
      let(:current_round) { rounds.second }

      before do
        init_battles_for round
        round.update_attributes(opened_for_bets: false)
        league.ranking_for(round: round)
        init_battles_for current_round
      end

      it "should return the ranking considering the result on each battle" do
        battles = league.battles_for(round: current_round)
        max_scores = current_round.matches.count
        match = current_round.matches.last

        battles[0].guest.set_bet_for(match, 1, 0)

        battles[1].host.update_attributes(name: "A")
        battles[1].guest.update_attributes(name: "B")

        current_round.update_attributes(opened_for_bets: false)

        ranking = league.ranking_for(round: current_round)

        expect(ranking.placements[0]).to eq({"id" => battles[0].host.id, "name" => battles[0].host.name, "games" => 2, "wins" => 1, "draws" => 1, "loss" => 0, "scores_pro" => 2 * max_scores, "scores_against" => 2 * max_scores - 1})
        expect(ranking.placements[1]).to eq({"id" => battles[1].host.id, "name" => battles[1].host.name, "games" => 2, "wins" => 0, "draws" => 2, "loss" => 0, "scores_pro" => 2 * max_scores, "scores_against" => 2 * max_scores})
        expect(ranking.placements[2]).to eq({"id" => battles[1].guest.id, "name" => battles[1].guest.name, "games" => 2, "wins" => 0, "draws" => 2, "loss" => 0, "scores_pro" => 2 * max_scores, "scores_against" => 2 * max_scores})
        expect(ranking.placements[3]).to eq({"id" => battles[0].guest.id, "name" => battles[0].guest.name, "games" => 2, "wins" => 0, "draws" => 1, "loss" => 1, "scores_pro" => 2 * max_scores - 1, "scores_against" => 2 * max_scores})
      end
    end
  end
end
