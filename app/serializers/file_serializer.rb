# frozen_string_literal: true

class FileSerializer < ActiveModel::Serializer
  attributes :id, :service_url
end
