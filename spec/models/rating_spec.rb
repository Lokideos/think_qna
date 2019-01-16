# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rating, type: :model do
  it { should belong_to :question }
  it { should validate_presence_of :score }

  context 'Methods' do
    let(:rating) { create(:rating) }

    describe '#score_up' do
      it 'increases score value by 1' do
        rating.score_up
        rating.reload

        expect(rating.score).to eq 1
      end
    end

    describe '#score_down' do
      it 'decreases score value by 1' do
        rating.score_down
        rating.reload

        expect(rating.score).to eq(-1)
      end
    end
  end
end
