require 'net/http'
require 'net/https'
require 'json'
require 'config'

module PaypalAdaptive
  class IpnNotification
    
    def initialize
      @@config ||= PaypalAdaptive::Config.new
      @@paypal_base_url ||= @@config.paypal_base_url
      @@ssl_cert_path ||= @@config.ssl_cert_path
      @@ssl_cert_file ||= @@config.ssl_cert_file
    end
    
    def send_back(data)
      data = "cmd=_notify-validate&#{data}"
      url = URI.parse @@paypal_base_url
      http = Net::HTTP.new(url.host, 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.ca_path = @@ssl_cert_path unless @@ssl_cert_path.nil?
      http.ca_file = @@ssl_cert_file unless @@ssl_cert_file.nil?
      
      path = "#{@@paypal_base_url}/cgi-bin/webscr"
      resp, response_data = http.post(path, data)
      
      case resp
        when Net::HTTPSuccess
           @verified = response_data == "VERIFIED"
        else
          resp.error!
      end
    end
    
    def verified?
      @verified
    end
    
  end
end