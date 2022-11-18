# frozen_string_literal: true
# OVERRIDE here to add Adventist's custom color for their header & footer

# rubocop:disable Metrics/ClassLength
module Hyrax
  module Forms
    module Admin
      # An object to model and persist the form data for the appearance
      # customization menu
      class Appearance
        extend ActiveModel::Naming

        DEFAULT_FONTS = {
          'body_font'     => 'Helvetica Neue, Helvetica, Arial, sans-serif;',
          'headline_font' => 'Helvetica Neue, Helvetica, Arial, sans-serif;'
        }.freeze

        # OVERRIDE here to add custom_adl_header_footer_color
        DEFAULT_COLORS = {
          'header_background_color'          => '#000000',
          'header_text_color'                => '#FFFFFF',
          'searchbar_background_color'       => '#000000',
          'searchbar_background_hover_color' => '#000000',
          'searchbar_text_color'             => '#FFFFFF',
          'searchbar_text_hover_color'       => '#FFFFFF',
          'link_color'                       => '#FFFFFF',
          'link_hover_color'                 => '#FFBD42',
          'footer_link_color'                => '#FFFFFF',
          'footer_link_hover_color'          => '#000000',
          'primary_button_background_color'  => '#CE8C00',
          'default_button_background_color'  => '#FFFFFF',
          'default_button_border_color'      => '#5B5B5B',
          'default_button_text_color'        => '#FFFFFF',
          'active_tabs_background_color'     => '#FFFFFF',
          'facet_panel_background_color'     => '#000000',
          'facet_panel_text_color'           => '#FFFFFF',
          'custom_adl_header_footer_color'   => '#CE8C00'
        }.freeze

        DEFAULT_VALUES = DEFAULT_FONTS.merge(DEFAULT_COLORS).freeze

        # @param [Hash] attributes the list of parameters from the form
        def initialize(attributes = {})
          @attributes = attributes
        end

        attr_reader :attributes
        private :attributes

        # This allows this object to route to the correct path
        def self.model_name
          ActiveModel::Name.new(self, Hyrax, "Hyrax::Admin::Appearance")
        end

        # Override this method if your form takes more than just the customization_params
        def self.permitted_params
          customization_params
        end

        # Required to back a form
        def to_key
          []
        end

        # Required to back a form (for route determination)
        def persisted?
          true
        end

        # The font for the body copy
        def body_font
          block_for('body_font')
        end

        # The font for the headline copy
        def headline_font
          block_for('headline_font')
        end

        # The color for the background of the header and footer bars
        def header_background_color
          block_for('header_background_color')
        end

        # The color for the text in the header bar
        def header_text_color
          block_for('header_text_color')
        end

        # The color for the background of the search navbar
        def searchbar_background_color
          block_for('searchbar_background_color')
        end

        def searchbar_background_color_alpha
          convert_to_rgba(searchbar_background_color, 0.4)
        end

        def searchbar_background_color_active
          darken_color(searchbar_background_color, 0.35)
        end

        def searchbar_background_hover_color
          block_for('searchbar_background_hover_color')
        end

        def searchbar_background_hover_color_alpha
          convert_to_rgba(searchbar_background_hover_color, 0.15)
        end

        def searchbar_text_color
          block_for('searchbar_text_color')
        end

        def searchbar_text_hover_color
          block_for('searchbar_text_hover_color')
        end

        # The color links
        def link_color
          block_for('link_color')
        end

        # The color for links when hover or focus state
        def link_hover_color
          block_for('link_hover_color', darken_color(link_color, 0.15))
        end

        # The color for links in the footer
        def footer_link_color
          block_for('footer_link_color')
        end

        # The color for links when hover in the footer
        def footer_link_hover_color
          block_for('footer_link_hover_color')
        end

        # PRIMARY BUTTON COLORS
        # The background color for "primary" buttons
        def primary_button_background_color
          block_for('primary_button_background_color')
        end

        # The border color for "primary" buttons
        def primary_button_border_color
          @primary_button_border ||= darken_color(primary_button_background_color, 0.05)
        end

        # The mouse over color for "primary" buttons
        def primary_button_hover_background_color
          darken_color(primary_button_background_color, 0.1)
        end

        # The mouse over color for the border of "primary" buttons
        def primary_button_hover_border_color
          darken_color(primary_button_border_color, 0.12)
        end

        # The color for the background of active "primary" buttons
        def primary_button_active_background_color
          darken_color(primary_button_background_color, 0.1)
        end

        # The color for the border of active "primary" buttons
        def primary_button_active_border_color
          darken_color(primary_button_border_color, 0.12)
        end

        # The color for the background of focused "primary" buttons
        def primary_button_focus_background_color
          darken_color(primary_button_background_color, 0.1)
        end

        # The color for the border of focused "primary" buttons
        def primary_button_focus_border_color
          darken_color(primary_button_border_color, 0.25)
        end

        # The custom css module
        def custom_css_block
          # we want to be able to read the css
          block_for('custom_css_block', '/* custom stylesheet */').html_safe
        end

        # DEFAULT BUTTON COLORS

        # The background color for "default" buttons
        def default_button_background_color
          block_for('default_button_background_color')
        end

        # The border color for "default" buttons
        def default_button_border_color
          block_for('default_button_border_color')
        end

        # The text color for "default" buttons
        def default_button_text_color
          block_for('default_button_text_color')
        end

        # The mouse over color for "default" buttons
        def default_button_hover_background_color
          darken_color(default_button_background_color, 0.1)
        end

        # The mouse over color for the border of "default" buttons
        def default_button_hover_border_color
          darken_color(default_button_border_color, 0.12)
        end

        # The color for the background of active "default" buttons
        def default_button_active_background_color
          darken_color(default_button_background_color, 0.1)
        end

        # The color for the border of active "default" buttons
        def default_button_active_border_color
          darken_color(default_button_border_color, 0.12)
        end

        # The color for the background of focused "default" buttons
        def default_button_focus_background_color
          darken_color(default_button_background_color, 0.1)
        end

        # The color for the border of focused "default" buttons
        def default_button_focus_border_color
          darken_color(default_button_border_color, 0.25)
        end

        # The color for the background of the home page nav-pills tab with active class
        def active_tabs_background_color
          block_for('active_tabs_background_color')
        end

        # The color for the border of navbar-inverse
        def header_background_border_color
          darken_color(header_background_color, 0.25)
        end

        # The color for the facet panel header background color
        def facet_panel_background_color
          block_for('facet_panel_background_color')
        end

        # The color for the facet header text
        def facet_panel_text_color
          block_for('facet_panel_text_color')
        end

        # The color for the facet borders
        def facet_panel_border_color
          darken_color(facet_panel_background_color, 0.12)
        end

        # Persist the form values
        def update!
          self.class.customization_params.each do |field|
            update_block(field, attributes[field]) if attributes[field]
          end
        end

        # OVERRIDE here to add adventist's custom header & footer
        def custom_adl_header_footer_color
          block_for('custom_adl_header_footer_color')
        end

        # A list of parameters that are related to customizations
        # OVERRIDE here to add custom_adl_header_footer_color
        def self.customization_params
          %i[
            body_font
            headline_font
            header_background_color
            header_text_color
            link_color
            link_hover_color
            footer_link_color
            footer_link_hover_color
            primary_button_background_color
            default_button_background_color
            default_button_border_color
            default_button_text_color
            active_tabs_background_color
            facet_panel_background_color
            facet_panel_text_color
            searchbar_background_color
            searchbar_background_hover_color
            searchbar_text_color
            searchbar_text_hover_color
            custom_css_block
            custom_adl_header_footer_color
          ]
        end

        def font_import_body_url
          body = body_font.split('|').first.to_s.tr(" ", "+")
          # we need to be able to read the url to import fonts
          "fonts.googleapis.com/css?family=#{body}"
        end

        def font_import_headline_url
          headline = headline_font.split('|').first.to_s.tr(" ", "+")
          "fonts.googleapis.com/css?family=#{headline}"
        end

        def font_body_family
          format_font_names(body_font)
        end

        def font_headline_family
          format_font_names(headline_font)
        end

        private

          def darken_color(hex_color, adjustment = 0.2)
            amount = 1.0 - adjustment
            hex_color = hex_color.delete('#')
            rgb = hex_color.scan(/../).map { |color| (color.to_i(16) * amount).round }
            format("#%02x%02x%02x", *rgb)
          end

          def convert_to_rgba(hex_color, alpha = 0.5)
            hex_color = hex_color.delete('#')
            rgb = hex_color.scan(/../).map(&:hex)
            "rgba(#{rgb[0]}, #{rgb[1]}, #{rgb[2]}, #{alpha})"
          end

          def block_for(name, dynamic_default = nil)
            block = ContentBlock.find_by(name: name)
            has_value = block&.value.present?
            has_value ? block.value : DEFAULT_VALUES[name] || dynamic_default
          end

          # Persist a key/value tuple as a ContentBlock
          # @param [Symbol] name the identifier for the ContentBlock
          # @param [String] value the value to set
          def update_block(name, value)
            ContentBlock.find_or_create_by(name: name.to_s).update!(value: value)
          end

          def format_font_names(font_style)
            # the fonts come with `Font Name:font-weight` - this removes the weight
            parts = font_style.split(':')
            # Google fonts use `+` in place of spaces. This fixes it for CSS.
            parts[0].tr('+', ' ').html_safe
          end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
