require 'net/http'
require 'json'

class GraphQLClient
  def initialize(endpoint = 'http://sod-pbs:8080/graphql', token_path = nil)
    @endpoint = endpoint
    @token_path = token_path
    @token = read_token
  end

  def execute_query(query)
    make_request(query)
  end

  private

  def read_token
    username = ENV['USER'] || `whoami`.strip
    token_file = @token_path || "/scratch/pbs_tokens/#{username}.token"
    File.read(token_file).strip
  rescue Errno::ENOENT => e
    puts "Error: Token file not found - #{e.message}"
    exit 1
  end

  def make_request(query)
    uri = URI(@endpoint)
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{@token}"
    request.body = JSON.generate({ query: query })

    response = http.request(request)
    response.body
  rescue StandardError => e
    puts "Error: #{e.message}"
    exit 1
  end
end
