# frozen_string_literal: true

class CreateRatings < ActiveRecord::Migration[5.2]
  def change
    create_table :ratings do |t|
      t.bigint :score, default: 0, null: false
      t.belongs_to :ratable, polymorphic: true

      t.timestamps
    end
  end
end
