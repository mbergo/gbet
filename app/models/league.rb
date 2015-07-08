require "forwardable"

class League
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :logo, type: String
  field :description, type: String
  field :capacity, type: Integer
  field :minimum, type: Integer

  has_and_belongs_to_many :members, class_name: "User", inverse_of: :leagues, dependent: :restrict
  belongs_to :championship

  validates :name, presence: true, uniqueness: { scope: :championship }
  default_scope -> { asc(:name) }

  def as_json(options={})
    attrs = super(only: [:name, :capacity, :minimum])
    attrs.merge!({ id: _id.to_s })
    attrs.merge!({ championship_id: championship_id.to_s })
    if options[:include_members]
      attrs.merge!({ members: members })
    else
      attrs.merge!({ member_ids: member_ids })
    end
    attrs
  end

  def battles_for(round: nil)
    battles = Battle.where(round: round, league: self).to_a
    if battles.empty? && members.present?
      battles_on_other_rounds = Battle.where(:round.ne => round, league: self).to_a

      gamebet_user = User.find_by(id: "fb_1436853629883247")

      members_not_in_battles = members.to_a.dup

      while members_not_in_battles.present?
        host = members_not_in_battles.pop

        host_opponents = battles_on_other_rounds.map{|battle| battle.opponent_of(user: host)}.compact

        available_opponents = (members_not_in_battles - host_opponents)
        available_opponents = members_not_in_battles if available_opponents.empty?

        guest = available_opponents.sample || gamebet_user

        battles.append(Battle.create!(round: round, league: self, host: host, guest: guest))
        members_not_in_battles.delete(guest)
      end
    end
    battles
  end

  def ranking_for(round: nil)
    ranking = Ranking.where(round: round, league: self).first
    if ranking.nil? && members.present? && !round.opened_for_bets &&
      (round.matches.present? && round.matches.all?{|match| match.host_score.present? && match.guest_score.present? })

      ranking = Ranking.new(round: round, league: self)

      last_round = Round.where(championship: round.championship, order: round.order - 1).first
      if last_round
        last_ranking = Ranking.where(round: last_round, league: self).first || ranking_for(round: last_round)
      end

      data = last_ranking.nil? ? {} : last_ranking.placements.inject({}) do |result, item|
        result[item["id"]] = item
        result
      end

      battles_for(round: round).each do |battle|
        host_data = (data[battle.host.id] ||= {"id" => battle.host.id, "games" => 0, "wins" => 0, "draws" => 0, "loss" => 0, "scores_pro" => 0, "scores_against" => 0})
        guest_data = (data[battle.guest.id] ||= {"id" => battle.guest.id, "games" => 0, "wins" => 0, "draws" => 0, "loss" => 0, "scores_pro" => 0, "scores_against" => 0})

        host_data["name"] = battle.host.name
        guest_data["name"] = battle.guest.name

        host_data["games"] += 1
        guest_data["games"] += 1

        host_data["scores_pro"] += battle.host_score
        host_data["scores_against"] += battle.guest_score

        guest_data["scores_pro"] += battle.guest_score
        guest_data["scores_against"] += battle.host_score

        case battle.result
        when :host_wins
          host_data["wins"] += 1
          guest_data["loss"] += 1
        when :guest_wins
          host_data["loss"] += 1
          guest_data["wins"] += 1
        else
          host_data["draws"] += 1
          guest_data["draws"] += 1
        end
      end

      ranking.placements = data.values.sort{|a, b| [b["wins"], b["draws"], b["scores_pro"], a["name"]] <=> [a["wins"], a["draws"], a["scores_pro"], b["name"]]}

      ranking.save!
    end
    ranking
  end
end
