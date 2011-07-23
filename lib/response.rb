module PaypalAdaptive
  class Response < Hash    
    class PreapprovalCancelled < StandardError; end
    class PaypalError < StandardError; end

    def initialize(response)
      @@config ||= PaypalAdaptive::Config.new
      @@paypal_base_url ||= @@config.paypal_base_url
      self.merge!(response)
    end

    def success?
      dig('responseEnvelope', 'ack') == 'Success'
    end

    def error_code
      dig('error', 0, 'errorId')
    end

    def error_message
      dig('error', 0, 'message')
    end

    def raise!
      case error_code
        when '569013' then raise PreapprovalCancelled, error_message
        else raise PaypalError, error_message
      end
    end
    
    def approve_paypal_payment_url
      "#{@@paypal_base_url}/webscr?cmd=_ap-payment&paykey=#{self['payKey']}" if self['payKey']
    end

    def preapproval_paypal_payment_url
      "#{@@paypal_base_url}/webscr?cmd=_ap-preapproval&preapprovalkey=#{self['preapprovalKey']}" if self['preapprovalKey']
    end
    
  protected

    def dig(*path)
      path.inject(self) do |location, key|
        location.respond_to?(:[]) ? location[key] : nil
      end
    end
  end
end
