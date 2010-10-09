# -*- coding: utf-8 -*-
# must use oauth library.
class OAuthRubytter < Rubytter
  attr_accessor :login

  # access_token: must be instance of OAuth::AccessToken
  def initialize(access_token, options = {})
    super(nil, nil, options)
    @access_token = access_token
  end

  def get(path, params = {})
    path += '.json'
    param_str = to_param_str(params)
    path = path + '?' + param_str unless param_str.empty?
    parse_response(@access_token.get(path, @header))
  end

  def post(path, params = {})
    path += '.json'
    parse_response(@access_token.post(path, params.stringify_keys, @header))
  end

  def put(path, params = {})
    path += '.json'
    parse_response(@access_token.put(path, params.stringify_keys, @header))
  end

  def delete(path, params = {})
    path += '.json'
    param_str = to_param_str(params)
    path = path + '?' + param_str unless param_str.empty?
    parse_response(@access_token.delete(path, @header))
  end

  def parse_response(res)
    json_data = JSON.parse(res.body)
    case res.code
    when "200"
      structize(json_data)
    else
      raise APIError.new(json_data['error'], res)
    end
  end
end
