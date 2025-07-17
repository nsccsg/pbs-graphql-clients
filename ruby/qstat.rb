#!/usr/bin/env ruby

require './client'

# Query qstat
# job_id, job_name, partition, status
query = <<~GRAPHQL
  query myJobListing {
    jobs(filter: {}) {
      edges {
      node {
        jobId
	name
	owner
	status {
	  state
	}
      }
      }
    }
  }
GRAPHQL

client = GraphQLClient.new
result = client.execute_query(query)
puts result
