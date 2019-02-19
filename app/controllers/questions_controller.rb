# frozen_string_literal: true

class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]

  include Authorized
  include Rated

  def index
    @questions = Question.all
    @search = Search.new
  end

  # rubocop:disable Metrics/AbcSize
  def show
    @answer = question.answers.build
    @comment = question.comments.build
    question.links.build
    question.answers.each { |answer| answer.links.build }
    gon.current_user_id = current_user.id if current_user
    gon.question_id = question.id
  end
  # rubocop:enable Metrics/AbcSize

  def new
    question.links.build
    question.build_reward
  end

  def edit; end

  def create
    @question = current_user.questions.new(question_params)

    if question.save
      redirect_to question, notice: I18n.t('notifications.created', resource: question.class.model_name.human)
    else
      render :new
    end
  end

  def update
    question.update(question_params)
  end

  def destroy
    question.destroy
    redirect_to questions_path, notice: I18n.t('notifications.deleted', resource: question.class.model_name.human)
  end

  def subscribe
    current_user.subscribe(question)
    render json: question.id, status: :ok
  end

  def unsubscribe
    current_user.unsubscribe(question)
    render json: question.id, status: :ok
  end

  private

  def question_params
    params.require(:question).permit(:title, :body,
                                     files: [], links_attributes: %i[name url], reward_attributes: %i[title image])
  end

  def question
    @question ||= params[:id] ? Question.with_attached_files.find(params[:id]) : Question.new
  end

  helper_method :question
end
