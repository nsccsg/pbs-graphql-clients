#!/usr/bin/env ruby

require 'net/http'
require 'json'

endpoint = 'http://sod-pbs:8080/graphql'

begin
  # Read the token from file
  username = ENV['USER'] || `whoami`.strip
  token_file = "/scratch/pbs_tokens/#{username}.token"
  token = File.read(token_file).strip
rescue Errno::ENOENT => e
  puts "Error: Token file not found - #{e.message}"
  exit 1
end

begin
  # Set up the HTTP request
  uri = URI(endpoint)
  http = Net::HTTP.new(uri.host, uri.port)

  # Create the request
  request = Net::HTTP::Post.new(uri)
  request['Content-Type'] = 'application/json'
  request['Authorization'] = "Bearer #{token}"

  # Set the request body
  request.body = JSON.generate({
    query: "query myMachineListing { machines (orderBy:M_NAME_ASC) { edges { node { name state } } } }"
  })

  # Make the request and print the response
  response = http.request(request)
  puts response.body

rescue StandardError => e
  puts "Error: #{e.message}"
  exit 1
end
