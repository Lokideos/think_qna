# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @comment = commentable.comments.new(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.json { render json: @comment }
      else
        format.json { render json: @comment.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  private

  def commentable
    @commentable ||= params[:question_id] ? Question.find(params[:question_id]) : Answer.find(params[:answer_id])
  end

  def comment
    @comment ||= params[:id] ? Comment.find(params[:id]) : commentable.comment.new
  end

  helper_method :comment, :commentable

  def comment_params
    params.require(:comment).permit(:body)
  end
end
