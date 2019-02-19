# frozen_string_literal: true

class SearchesController < ApplicationController
  authorize_resource

  before_action :load_questions, only: :create

  def create
    @search = Search.new(search_params)

    if @search.save
      redirect_to @search
    else
      render 'questions/index'
    end
  end

  def show
    @search_result = Question.search(Search.find(params[:id]).query)
  end

  private

  def search_params
    params.require(:search).permit(:query)
  end

  def load_questions
    @questions = Question.all
  end
end
