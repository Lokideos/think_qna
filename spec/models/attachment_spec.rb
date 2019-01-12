# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Attachment, type: :model do
  context 'Methods' do
    describe '.resource_permitted?' do
      let(:question) { create(:question) }

      it 'returns true if class name is among permitted class names' do
        expect(Attachment).to be_resource_permitted(question.class.to_s)
      end

      it 'returns false if class name is not among permitted class names' do
        bad_resource_class_name = 'Bad Class Name'
        expect(Attachment).to_not be_resource_permitted(bad_resource_class_name)
      end
    end
  end
end
