class ChampionshipsController < ApplicationController
  respond_to :json

  def index
    render json: Championship.all.to_a
  end

  def show
    render json: Championship.find(params[:id]).to_json(include_rounds: true)
  end
end
