module TumblrWrapper::HTTP

  def http_get(path, opts={signed: false}, params={})
    validate_oauth if opts[:signed]
    connection = Faraday.new TumblrWrapper.endpoint do |conn|
      conn.request :oauth, access_token if opts[:signed]
      conn.request :url_encoded
      conn.response :json, :content_type => /\bjson$/
      conn.adapter Faraday.default_adapter
    end

    response = if opts[:signed]
      connection.get(long_path(path), params)
    else
      parameters = params.merge({api_key: TumblrWrapper.consumer_key})
      connection.get(long_path(path), parameters)
    end
    TumblrWrapper::Response.new(response)
  end

  def http_post(path, body)
    validate_oauth
    connection = Faraday.new TumblrWrapper.endpoint do |conn|
      conn.request :oauth, access_token
      conn.request :url_encoded
      conn.response :json, :content_type => /\bjson$/
      conn.adapter Faraday.default_adapter
    end

    response = connection.post long_path(path), body
    TumblrWrapper::Response.new(response)
  end

  private
  def content_type
    'application/json'
  end

  def accept
    'application/json'
  end

  def long_path(path)
    raise NotImplementedError
  end

  def blank?(thing)
    thing.nil? || thing.length == 0
  end
end
