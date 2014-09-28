module WordcloudHelper
  def add_param(url, param_name, param_value)
    uri = URI(url)
    params = uri.query.nil? ? [] : URI.decode_www_form(uri.query)
    params << [param_name, param_value] unless params.include? param_name
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end
end
