module PaypalAdaptive
  class PreapprovalResponse < Response
    def preapproval_key
      self['preapprovalKey']
    end
    
    def preapproval_paypal_payment_url
      "#{@@paypal_base_url}/webscr?cmd=_ap-preapproval&preapprovalkey=#{preapproval_key}" if preapproval_key
    end
  end
end
