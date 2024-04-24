globals "workflow" "workflow_dispatch" {
  on = {
    workflow_dispatch = null # `{}` is also valid
    #push              = null
  }
  permissions = {
    contents = "read"
  }
  name = "workflow-dispatch"

  jobs = {
    workflow-dispatch = {
      # this value is coming from the global variable (ubuntu-latest)
      runs-on = tm_try(global.workflows.runs-on, ["ubuntu-22.04"])
      # this value uses local default (5)
      timeout-minutes = tm_try(global.workflows.timeout-mintes, 5)

      steps = [
        # each step is an object
        {
          name = "example step"
          run  = "echo \"hello world!\""
        }
      ]
    }
  }
}

generate_file ".github/workflows/workflow_dispatch.yaml" {
  stack_filter {
    project_paths = [
      "/"
    ]
  }
  content = tm_yamlencode(global.workflow.workflow_dispatch)
}
