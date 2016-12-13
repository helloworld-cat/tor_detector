require 'spec_helper'
require 'net/http'

describe TorDetector::Base do
  describe '#initialize' do
    let(:default_dns_ip) { '8.8.8.8' }
    let(:default_dns_port) { 53 }
    subject { TorDetector::Base.new }
    it { expect(subject.dns_ip).to eq(default_dns_ip) }
    it { expect(subject.dns_port).to eq(default_dns_port) }
  end

  describe '#call' do
    let(:tor_detector_instance) { TorDetector::Base.new }

    context 'with malformed IP' do
      let(:ip) { 'foobar' }
      subject { tor_detector_instance.call(ip) }
      it { expect { subject }.to raise_error(TorDetector::MalformedIP) }
    end

    context 'with not TOR IP' do
      let(:ip) { '1.2.3.4' }
      subject { tor_detector_instance.call(ip) }
      it { expect(subject).to eq(false) }
    end

    context 'with TOR IP' do
      let(:tor_exit_nodes) do
        uri = URI.parse('https://check.torproject.org/exit-addresses')
        resp = Net::HTTP.get(uri)
        resp.split("\n")
            .select{|i| i =~ /^ExitAddress/}
            .map{|j| j.split(' ')[1]}
      end
      let(:ip) { tor_exit_nodes.sample }

      subject { tor_detector_instance.call(ip) }
      it { expect(subject).to eq(true) }
    end
  end
end
