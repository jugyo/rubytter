# -*- coding: utf-8 -*-
# must use oauth library.
class OAuthRubytter < Rubytter
  # access_token: must be instance of OAuth::AccessToken
  def initialize(access_token, options = {})
    super(options)
    @access_token = access_token
  end

  def get(path, params = {})
    path += '.json'
    @access_token.get(path, params, @header)
  end

  def post(path, params = {})
    path += '.json'
    @access_token.post(path, params, @header)
  end
end
