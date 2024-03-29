# frozen_string_literal: true

RSpec.describe FcrepoEndpoint do
  let(:base_path) { 'foobar' }
  subject { described_class.new base_path: base_path }

  describe '.options' do
    it 'uses the configured application settings' do
      expect(subject.options[:base_path]).to eq base_path
    end
  end

  describe '#ping' do
    let(:url_prefix) { ActiveFedora::Fedora.instance.connection.connection.http.url_prefix.to_s }

    context 'when Fedora is accessible' do
      let(:success_response) { double(response: double(success?: true)) }

      it 'returns "Fedora is OK"' do
        allow(ActiveFedora::Fedora.instance.connection).to receive(:head).with(url_prefix).and_return(success_response)
        expect(subject.ping).to eq("Fedora is OK")
      end
    end

    context 'when Fedora is down' do
      let(:failure_response) { double(response: double(success?: false)) }

      it 'returns "Fedora is Down"' do
        allow(ActiveFedora::Fedora.instance.connection).to receive(:head).with(url_prefix).and_return(failure_response)
        expect(subject.ping).to eq("Fedora is Down")
      end
    end

    context 'when an error occurs' do
      it 'returns a custom error message with the error details' do
        error_message = "Network error"
        allow(ActiveFedora::Fedora.instance.connection).to receive(:head).and_raise(StandardError.new(error_message))
        expect(subject.ping).to eq("Error checking Fedora status: #{error_message}")
      end
    end
  end
end
