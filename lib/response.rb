module PaypalAdaptive
  class Response < Hash    
    class PaypalError < StandardError; end
    class SystemError < PaypalError; end
    class InternalError < PaypalError; end

    def initialize(response)
      @@config ||= PaypalAdaptive::Config.new
      @@paypal_base_url ||= @@config.paypal_base_url
      self.merge!(response)
    end
    
    def deeper_success?
      true
    end

    def shallow_success?
      ['Success', 'SuccessWithWarning'].include? dig('responseEnvelope', 'ack')
    end

    def success?
      if !shallow_success?
        false
      else
        deeper_success?
      end
    end

    def error_code
      if !shallow_success?
        dig('error', 0, 'errorId')
      else
        deeper_error_code
      end
    end

    def error_message
      if !shallow_success?
        dig('error', 0, 'message')
      else
        deeper_error_message
      end
    end

    def raise!
      if !shallow_success?
        case error_code
          when '500000' then raise SystemError, error_message
          when '520002' then raise InternalError, error_message
          else raise PaypalError, error_message
        end
      else
        deeper_raise!
      end
    end
    
  protected

    def dig(*path)
      path.inject(self) do |location, key|
        location.respond_to?(:[]) ? location[key] : nil
      end
    end
  end
end
