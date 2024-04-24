globals "workflows" {
  # default runner image
  runs-on = ["ubuntu-latest"]

  # pin actions by commit hashes instead of tags: https://blog.rafaelgss.dev/why-you-should-pin-actions-by-commit-hash
  versions = {
    checkout   = "b4ffde65f46336ab88eb53be808477a3936bae11" # v4.1.1 https://github.com/actions/checkout
    alls-green = "05ac9388f0aebcb5727afa17fcccfecd6f8ec5fe" # v1.2.2 https://github.com/re-actors/alls-green
  }
}

globals "repository" {
  # which environments to manage
  environments = ["dev", "staging", "prod"]
  # run workflows on all environments regardless of change
  # reducing the number of jobs based on changes optimises github actions runtime
  always_run = false
  # toggle chaotic good example for workflow generation (json > yaml)
  chaotic_good = false
}

# dummy configuration change
