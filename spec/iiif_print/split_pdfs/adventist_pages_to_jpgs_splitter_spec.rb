# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IiifPrint::SplitPdfs::AdventistPagesToJpgsSplitter do
  describe '.new' do
    subject { described_class.new(path, suffixes: ["spec.rb"], splitter: splitter) }

    let(:splitter) { Class.new { def initialize(path); end } }

    context 'when given path ends in the given suffix' do
      let(:path) { __FILE__ }

      it { is_expected.to eq([]) }
    end

    context 'when given path does not end in the suffix' do
      let(:path) { "#{__FILE__}.hello.rb" }

      it { is_expected.to be_a(splitter) }
    end
  end
end
