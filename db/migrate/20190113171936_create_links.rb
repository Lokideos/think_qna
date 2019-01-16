# frozen_string_literal: true

class CreateLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :links do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.text :body
      t.belongs_to :linkable, polymorphic: true

      t.timestamps
    end
  end
end
