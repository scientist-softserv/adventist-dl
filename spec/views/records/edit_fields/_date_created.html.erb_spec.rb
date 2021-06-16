# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'records/edit_fields/_date_created.html.erb', type: :view do
  let(:work) { GenericWork.new }
  let(:form) { Hyrax::GenericWorkForm.new(work, nil, controller) }
  let(:form_template) do
    %(
      <%= simple_form_for [main_app, @form] do |f| %>
        <%= render "records/edit_fields/date_created", f: f, key: 'date_created' %>
      <% end %>
    )
  end

  before do
    assign(:form, form)
    assign(:curation_concern, work)
    render inline: form_template
  end

  describe 'date_created edit_field' do
    it 'is an optional field' do
      expect(rendered).to have_selector('div[class="form-group optional generic_work_date_created"]')
    end

    it 'has a date format' do
      expect(rendered).to have_selector('input[type="date"]')
    end
  end
end
