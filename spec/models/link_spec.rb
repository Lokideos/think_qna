# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Link, type: :model do
  context 'Associations' do
    it { should belong_to :linkable }
  end

  context 'Validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :url }
    it { should allow_value('https://google.com').for(:url) }
    it { should_not allow_value('123456').for(:url) }
  end

  context 'Methods' do
    describe '#add_gist_content' do
      let(:gist_url) { 'https://gist.github.com/Lokideos/815f3eea3f00a35ff48ea2984457b673' }

      it 'returns gist content if url leads to gist' do
        link = Link.new(name: 'Link name', url: gist_url)
        expect(link.add_gist_content.first.last.content).to eq 'Hello Gist!'
      end

      it 'does not return gist content if url does not lead to gist' do
        link = Link.new(name: 'Link name', url: 'https://google.ru')
        expect(link.add_gist_content).to be_nil
      end
    end
  end
end
