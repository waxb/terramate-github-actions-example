globals "workflow" "main" {
  on = {
    pull_request = {
      #branches = ["main"]
    }
    #workflow_dispatch = {} # `null` is also valid
    #push              = {}
  }
  # we are passing down this permission to the called workflows
  permissions = {
    pull-requests = "read"
    contents      = "read"
  }
  name = "main"
  jobs = {
    # paths filter doesn't work with `workflow` call event, hence we are prefiltering the
    # input matrix based on changes of the environment paths
    # also matrix outputs aren't supported yet, hence the generation in a single job
    # https://github.com/actions/runner/pull/2477#issuecomment-1501003600
    generate-matrix = {
      if      = !tm_try(global.repository.always_run, false)
      runs-on = tm_try(global.workflows.runs-on, ["ubuntu-latest"])
      outputs = {
        matrix = "$${{ steps.generate.outputs.matrix }}"
      }
      steps = [
        {
          name = "checkout"
          uses = "actions/checkout@${global.workflows.versions.checkout}"
          with = {
            fetch-depth = 0
          }
        },
        {
          name = "generate matrix"
          id   = "generate"
          run  = <<-EOF
            output="$(for i in ${tm_join(" ", global.repository.environments)} ; do [[ -z $(git diff --name-only origin/${global.repository.main}...HEAD | grep -E "stacks/$${i}") ]] || echo $i ; done)"
            [ -z "$output" ] || echo "matrix=[\""$${output//[ ]/\", \"}"\"]" >> "$GITHUB_OUTPUT"
          EOF
        }
      ]
    }
    call-workflows = {
      needs = tm_ternary(
        tm_try(global.repository.always_run, false),
        [],
        ["generate-matrix"]
      )
      # if condition is being evaluated before strategy.matrix so checking for empty output is sufficient
      if = tm_ternary(
        tm_try(global.repository.always_run, false),
        true,
        "$${{ needs.generate-matrix.outputs.matrix != '' }}"
      )
      strategy = {
        matrix = {
          environments = tm_ternary(
            tm_try(global.repository.always_run, false),
            global.repository.environments,
            "$${{ fromJSON(needs.generate-matrix.outputs.matrix) }}"
          )
        }
      }
      uses = "./.github/workflows/called.yaml"
      with = {
        environment = "$${{ matrix.environments }}"
      }
      # pass down token to called workflow
      secrets = "inherit"
    }
    # gather outputs of matrix jobs above: `all-passed` can be set as
    # required status check for branch protection
    all-passed = {
      runs-on = tm_try(global.workflows.runs-on, ["ubuntu-latest"])
      if      = "always()"
      needs = [
        "generate-matrix",
        "call-workflows"
      ]
      steps = [
        {
          name = "check all jobs for approval"
          uses = "re-actors/alls-green@${global.workflows.versions.alls-green}"
          with = {
            # if we skip because no changes still mark as passed
            allowed-skips = tm_ternary(
              tm_try(global.repository.always_run, false),
              "generate-matrix",
              "call-workflows"
            )
            jobs = "$${{ toJSON(needs) }}"
          }
        }
      ]
    }
  }
}

generate_file ".github/workflows/main.yaml" {
  stack_filter {
    project_paths = [
      "/"
    ]
  }
  content = tm_ternary(
    global.repository.chaotic_good,
    # we can generate a valid yaml as a json because why not?
    tm_jsonencode(global.workflow.main),
    tm_yamlencode(global.workflow.main)
  )
}
