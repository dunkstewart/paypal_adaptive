module PaypalAdaptive
  class PayResponse < Response
    class PaymentExecError < Response::PaypalError; end
    
    def pay_key
      self['payKey']
    end
    
    def approve_paypal_payment_url
      "#{@@paypal_base_url}/webscr?cmd=_ap-payment&paykey=#{pay_key}" if pay_key
    end
    
    def deeper_success?
      !['ERROR', 'REVERSALERROR'].include? self['paymentExecStatus']
    end

    def deeper_error_code
      dig('payErrorList', 'payError', 0, 'error', 'errorId')
    end
    
    def deeper_error_message
      dig('payErrorList', 'payError', 0, 'error', 'message')
    end

    def deeper_raise!
      raise PaymentExecError, deeper_error_message
    end
  end
end
