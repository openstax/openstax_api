# http://stackoverflow.com/a/27413178

class ResponderWithPutContent < Roar::Rails::Responder
  def api_behavior(*args, &block)
    return display resource, :status => :ok if put? || \
                                               (respond_to?(:patch?) && patch?)
    super
  end
end
