#!/usr/bin/env python3

import os
import sys
import json
from gql import gql, Client
from gql.transport.requests import RequestsHTTPTransport

# Default GraphQL endpoint
DEFAULT_ENDPOINT = "http://sod-pbs:8080/graphql"


def qstat(query=None, endpoint=DEFAULT_ENDPOINT, token=None):
    if query is None:
        query = gql(
            """
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
        """
        )
    
    if token is None:
        # Get token from environment
        token = os.getenv("PBS_TOKEN")
    if not token:
        sys.stderr.write("Error: PBS_TOKEN environment variable not set\n")
        sys.exit(1)

    # Configure transport with authorization header
    transport = RequestsHTTPTransport(
        url=DEFAULT_ENDPOINT,
        headers={"Authorization": f"Bearer {token}"},
        verify=True,
        retries=3,
    )

    try:
        # Create GraphQL client
        client = Client(transport=transport, fetch_schema_from_transport=True)
        return client.execute(query)
    except Exception as e:
        sys.stderr.write(f"GraphQL Error: {e}\n")
        sys.exit(1)


if __name__ == "__main__":
    result = qstat()
    print(json.dumps(result, indent=2))
