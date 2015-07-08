class UsersController < ApplicationController
  respond_to :json

  before_filter :check_facebook_login, only: [:bets]

  def bets
    round = Round.find(params[:round_id])
    user = User.find(params[:user_id])

    if !round.opened_for_bets? || (user == current_user)
      bet = Bet.where(:round => round, :user => user)
      render json: bet.empty? ? [] : bet.first
    else
      render json: { message: "Can't see bets or this round and user" }, status: 403
    end
  end

end
