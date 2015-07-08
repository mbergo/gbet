class LeaguesController < ApplicationController
  respond_to :json

  def index
    render json: League.where(championship_id: params[:championship_id]).to_a
  end

  def show
    render json: League.find(params[:id]).to_json(include_members: true)
  end

  def ranking
    league = League.find(params[:league_id])
    order = league.championship.current_round.order
    ranking = nil
    while (order > 0) && ranking.nil?
      round = league.championship.rounds.detect{ |r| r.order == order}
      ranking = league.ranking_for(round: round)
      order -= 1
    end

    render json: ranking || {}
  end

end
