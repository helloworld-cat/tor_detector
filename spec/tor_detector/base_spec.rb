require 'spec_helper'
require 'net/http'

describe TorDetector::Base do
  let(:default_dns_ip) { '8.8.8.8' }
  let(:default_dns_port) { 53 }
  let(:default_timeout) { 5 }
  let(:valid_ip) { '1.2.3.4' }
  let(:invalid_ip) { 'foobar' }
  let(:tor_ip) do
    uri = URI.parse('https://check.torproject.org/exit-addresses')
    resp = Net::HTTP.get(uri)
    resp.split("\n")
        .select { |i| i =~ /^ExitAddress/ }
        .map { |j| j.split(' ')[1] }
        .take(10) # take most recents
        .sample(1)
        .first
  end

  describe '#initialize' do
    subject { TorDetector::Base.new }
    it { expect(subject.dns_ip).to eq(default_dns_ip) }
    it { expect(subject.dns_port).to eq(default_dns_port) }
    it { expect(subject.timeout).to eq(default_timeout) }
  end

  describe '#call' do
    let(:tor_detector_instance) { TorDetector::Base.new }

    context 'with malformed IP' do
      subject { tor_detector_instance.call(invalid_ip) }
      it { expect { subject }.to raise_error(TorDetector::MalformedIP) }
    end

    context 'with timeout' do
      it do
        allow(Timeout).to receive(:timeout).and_raise(Timeout::Error)
        expect { TorDetector::Base.new.call(valid_ip) }.to \
          raise_error(TorDetector::DNSTimeout)
      end
    end

    context 'without timeout' do
      it do
        allow(Timeout).to receive(:timeout).and_return(nil)
        expect { TorDetector::Base.new.call(valid_ip) }.to_not raise_error
      end
    end

    context 'with not TOR IP' do
      subject { tor_detector_instance.call(valid_ip) }
      it { expect(subject).to eq(false) }
    end

    context 'with TOR IP' do
      subject { tor_detector_instance.call(tor_ip) }
      it { expect(subject).to eq(true) }
    end
  end
end
