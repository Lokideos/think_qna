# frozen_string_literal: true

class ChangeBodyTypeToTextForAnswers < ActiveRecord::Migration[5.2]
  def change
    change_column :answers, :body, :text, null: false
  end
end
