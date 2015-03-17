# http://stackoverflow.com/a/27413178

class ResponderWithPutContent < Roar::Rails::Responder
  def api_behavior(*args, &block)
    if put?
      display resource, :status => :ok
    else
      super
    end
  end
end
