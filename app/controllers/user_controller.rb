class UserController < ApplicationController
  before_filter :check_facebook_login

  def index

  end

  def leagues
    render json: current_user.leagues.to_a.to_json(with_details: true)
  end

  def add_league
    league = League.find(params[:league_id])
    if current_user.leagues.none?{ |l| l.championship == league.championship }
      current_user.leagues << league
      current_user.save!
      render json: { message: "Added to league" }
    else
      render json: { message: "Already on a league to this championship" }, status: 406
    end
  end

  def delete_league
    league = current_user.leagues.find(params[:league_id])
    current_user.leagues.delete(league)
    current_user.save!
    render json: { message: "Removed from league" }
  end

  def bets
    bet = Bet.where(:round_id => params[:round_id], :user => current_user)
    render json: bet.empty? ? [] : bet.first
  end

  def bet
    match = Match.where(:_id => params[:match_id], :round_id => params[:round_id]).first
    if match.present? && current_user.set_bet_for(match, params[:host_score], params[:guest_score])
      render json: { message: "Bet recorded" }
    else
      render json: { message: "Bet not recorded" }, status: 406
    end
  end

  def battles
    battles = Battle.where(:round_id => params[:round_id]).select{|battle| (battle.host == current_user) || (battle.guest == current_user)}.inject({}) do |result, battle|
      result[battle.league_id] = battle.attributes.slice("host_id", "guest_id")
      result
    end

    render json: battles
  end
end
