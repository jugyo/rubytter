# -*- coding: utf-8 -*-
# must use oauth library.
class OAuthRubytter < Rubytter
  # access_token: must be instance of OAuth::AccessToken
  def initialize(access_token, options = {})
    super(nil, nil, options)
    @access_token = access_token
  end

  def get(path, params = {})
    path += '.json'
    param_str = to_param_str(params)
    path = path + '?' + param_str unless param_str.empty?
    structize(@access_token.get(path, @header))
  end

  def post(path, params = {})
    path += '.json'
    structize(@access_token.post(path, params.stringify_keys, @header))
  end

  def put(path, params = {})
    path += '.json'
    structize(@access_token.put(path, params, @header))
  end

  def delete(path, params = {})
    path += '.json'
    param_str = self.class.to_param_str(params)
    path = path + '?' + param_str unless param_str.empty?
    structize(@access_token.delete(path, @header))
  end

  def structize(res)
    json_data = JSON.parse(res.body)
    case res.code
    when "200"
      structize(json_data)
    else
      raise APIError.new(json_data['error'], res)
    end
  end
end
