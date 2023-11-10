# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DestroyableChildren, type: :model do
  describe Image do
    let(:parent) { create(:image) }
    let(:child1) { create(:image) }
    let(:child2) { create(:image) }

    before do
      allow(parent).to receive(:ordered_works).and_return([child1, child2])
    end

    it 'destroys child works when the parent is destroyed' do
      expect { parent.destroy }.to change(Image, :count).by(-3)
    end
  end
end
