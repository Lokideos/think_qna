# frozen_string_literal: true

class Link < ApplicationRecord
  after_validation :add_gist_content

  GIST_ADDRESS_REGEXP = %r{^https://gist.github.com/[\w\W]*$}.freeze

  belongs_to :linkable, polymorphic: true

  validates :name, :url, presence: true
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp, message: I18n.t('errors.corret_url_address') }

  def add_gist_content
    gist_content if url&.match?(GIST_ADDRESS_REGEXP)
  end

  private

  def gist_content
    self.body = ''
    service = Services::GistReadService.new(url)
    service.call.files.each { |file| self.body += "#{file.first}\n\n#{file.last.content}\n\n" }
  end
end
