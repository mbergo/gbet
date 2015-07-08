class RoundsController < ApplicationController
  respond_to :json

  def show
    render json: Round.find(params[:id]).to_json(include_matches: true)
  end

end
