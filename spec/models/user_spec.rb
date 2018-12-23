# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:questions) }

  describe '#author_of?' do
    let(:author) { create(:user) }
    let(:non_author) { create(:user) }
    let(:question) { create(:question, user: author) }

    context 'For author of the question' do
      it 'should return true' do
        expect(author.author_of?(question)).to be_truthy
      end
    end

    context 'For user, who is not author of the question' do
      it 'should return false' do
        expect(non_author.author_of?(question)).to be_falsey
      end
    end
  end
end
