# frozen_string_literal: true

class ShortCommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :created_at, :updated_at
end
