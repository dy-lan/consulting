require 'octokit'

module Connection
  def self.create_connection(
    access_token: '',
    api_endpoint: '',
    auto_paginate: true,
    connection_options: { request: { open_timeout: 5, timeout: 5 } },
    per_page: 100
  )
    Octokit.configure do |c|
      c.access_token = access_token
      c.api_endpoint = api_endpoint
      c.auto_paginate = auto_paginate
      c.connection_options = connection_options
      c.per_page = per_page
    end

    Octokit::Client.new
  end

  $client = create_connection
end
