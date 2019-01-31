# frozen_string_literal: true

class Api::V1::AnswersController < ApplicationController
  before_action :doorkeeper_authorize!
  skip_authorization_check

  def show
    unauthorized! if cannot? :access, :answers_public_api_call

    @answer = Answer.find(params[:id])
    render json: @answer
  end
end
