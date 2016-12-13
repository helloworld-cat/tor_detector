require 'ipaddr'
require 'resolv'

module TorDetector
  MalformedIP = Class.new(StandardError)

  # tor_detector = TorDetector::Base.new
  # tor_detector.call('1.2.3.4')
  class Base
    attr_reader :dns_ip,
                :dns_port

    def initialize(dns_ip = '8.8.8.8', dns_port = 53)
      @dns_ip   = dns_ip
      @dns_port = dns_port
    end

    def call(ip)
      IPAddr.new(ip)
      Resolv.getaddress(tor_hostname_for(ip)) == positive_tor_ip
    rescue IPAddr::InvalidAddressError
      raise MalformedIP
    rescue Errno::EHOSTUNREACH, Errno::ENETUNREACH, Resolv::ResolvError
      false
    end

    private

    def positive_tor_ip
      '127.0.0.2'
    end

    def reverse_ip(ip)
      ip.split('.').reverse.join('.')
    end

    def tor_hostname_for(ip)
      [
        reverse_ip(ip),
        dns_port,
        reverse_ip(dns_ip),
        'ip-port.exitlist.torproject.org'
      ].join('.')
    end
  end
end
