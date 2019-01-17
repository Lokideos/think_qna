# frozen_string_literal: true

class CreateRatingChanges < ActiveRecord::Migration[5.2]
  def change
    create_table :rating_changes do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :rating, foreign_key: true

      t.timestamps
    end

    add_index :rating_changes, %i[user_id rating_id]
  end
end
