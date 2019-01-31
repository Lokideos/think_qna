# frozen_string_literal: true

module ApiHelpers
  def json
    @json ||= JSON.parse(response.body)
  end
end
