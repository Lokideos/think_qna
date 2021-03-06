# frozen_string_literal: true

class AddBestFlagToAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :answers, :best, :boolean, default: false, null: false
  end
end
