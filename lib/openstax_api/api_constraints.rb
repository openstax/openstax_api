class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end
  
  def matches?(req)
    @default || req.headers['Accept'].try(:include?, "application/vnd.#{OpenstaxApi.main_app_name.downcase}.openstax.v#{@version}")
  end
end
