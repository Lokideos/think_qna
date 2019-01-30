# frozen_string_literal: true

module Authorized
  extend ActiveSupport::Concern

  ACTIONS = %w[index create show].freeze

  included do
    before_action :authorize_resource
  end

  # rubocop:disable Metrics/AbcSize
  def authorize_resource
    return authorize! action_name.to_sym, controller_name[0..-2].capitalize.constantize if ACTIONS.include?(action_name)

    authorize! action_name.to_sym, send(controller_name[0..-2].to_sym)
  end
  # rubocop:enable Metrics/AbcSize
end
