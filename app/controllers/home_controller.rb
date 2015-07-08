class HomeController < ApplicationController
  def index
  end

  def show_partial
    render "partials/#{params[:name]}", layout: false
  end
end
