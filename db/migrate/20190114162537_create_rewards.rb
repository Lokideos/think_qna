# frozen_string_literal: true

class CreateRewards < ActiveRecord::Migration[5.2]
  def change
    create_table :rewards do |t|
      t.string :title, null: false
      t.belongs_to :question, foreign_key: true

      t.timestamps
    end
  end
end
