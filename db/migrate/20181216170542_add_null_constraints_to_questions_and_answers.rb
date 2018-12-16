# frozen_string_literal: true

class AddNullConstraintsToQuestionsAndAnswers < ActiveRecord::Migration[5.2]
  def change
    change_column :questions, :title, :string, null: false
    change_column :questions, :body, :text, null: false
    change_column :answers, :body, :string, null: false
  end
end
