globals "workflow" "called" {
  on = {
    workflow_call = {
      inputs = {
        environment = {
          required = true
          type     = "string"
        }
      }
    }
    # push = {
    #   # in case of push run only if there are changes on the managed environments
    #   paths = [for i in global.repository.environments : "stacks/${i}/**"]
    # }
  }
  jobs = {
    run-on-env = {
      permissions = {
        pull-requests = "read"
        contents      = "read"
      }
      runs-on = tm_try(global.workflows.runs-on, ["ubuntu-latest"])
      steps = [
        {
          name = "checkout"
          uses = "actions/checkout@${global.workflows.versions.checkout}"
          with = {
            fetch-depth = 0
          }
        },
        {
          name = "check for $${{ inputs.environment }}"
          run  = "cat stacks/$${{ inputs.environment }}/*"
        }
      ]
    }
  }
}

generate_file ".github/workflows/called.yaml" {
  stack_filter {
    project_paths = [
      "/"
    ]
  }
  content = tm_yamlencode(global.workflow.called)
}
