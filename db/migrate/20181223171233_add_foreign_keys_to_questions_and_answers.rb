# frozen_string_literal: true

class AddForeignKeysToQuestionsAndAnswers < ActiveRecord::Migration[5.2]
  def change
    add_belongs_to :questions, :user
    add_belongs_to :answers, :user
  end
end
