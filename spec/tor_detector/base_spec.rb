require 'spec_helper'

describe TorDetector::Base do
  describe '#initialize' do
    let(:default_dns_ip) { '8.8.8.8' }
    let(:default_dns_port) { 53 }
    subject { TorDetector::Base.new }
    it { expect(subject.dns_ip).to eq(default_dns_ip) }
    it { expect(subject.dns_port).to eq(default_dns_port) }
  end

  describe '#call' do
    context 'with malformed IP' do
      let(:ip) { 'foobar' }
      let(:tor_detector_instance) { TorDetector::Base.new }
      subject { tor_detector_instance.call(ip) }
      it { expect { subject }.to raise_error(TorDetector::MalformedIP) }
    end

    context 'with not TOR IP' do
      let(:ip) { '1.2.3.4' }
      let(:tor_detector_instance) { TorDetector::Base.new }
      subject { tor_detector_instance.call(ip) }
      it { expect(subject).to eq(false) }
    end
  end
end
