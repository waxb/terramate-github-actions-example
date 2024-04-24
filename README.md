# terramate-github-actions-example

this repository is for showcasing how do i generate github actions workflow files via [terramate](https://terramate.io). there are always tradeoffs but for me it is more readable and configurable than a simple yaml :-)
take what you need and could help on your journey!

# structure

```bash
.
├── imports                        # importing workflow generation logic from here
│   ├── called.tm.hcl
│   ├── main.tm.hcl
│   └── workflow_dispatch.tm.hcl
├── stacks                         # dummy environments for showcasing
│   ├── dev
│   │   ├── file
│   │   └── stack.tm.hcl
│   ├── prod
│   │   ├── file
│   │   └── stack.tm.hcl
│   └── staging
│       ├── file
│       └── stack.tm.hcl
├── workflows                     # generated workflow files
│   ├── called.yaml
│   ├── main.yaml
│   └── workflow_dispatch.yaml
├── LICENSE
├── README.md
├── globals.tm.hcl                # configuration
└── terramate.tm.hcl
```

## config

```hcl
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
```

## workflows

### workflow dispatch

a simple workflow triggered by the `workflow_dispatch` event. it has only one step greeting the world!

### main

this workflow optionally (`global.repository.always_run`) checks whether there are changes accross the managed environments (`global.repository.environments`) and generates the input of the matrix job which calls the reusable workflow `called.yaml`, then waits for all jobs to be finished to give a green light at the end. `all-passed` job can be set as required status check to keep the dynamic matrix at bay.

### called

this workflow aims to showcase how to do specific tasks on specific environments as a matrix.

# example pull requests

- change outside of environments
- always run
- change on `dev` and `staging`
- unmanage `prod`
- fail `dev`
- fail `staging` && always run
- chaotic good

# terramate

for more cool stuff, check out [terramate-io](https://github.com/orgs/terramate-io/repositories)
