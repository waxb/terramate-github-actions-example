import {
  source = "imports/workflow_dispatch.tm.hcl"
}

import {
  source = "imports/main.tm.hcl"
}

import {
  source = "imports/called.tm.hcl"
}

stack {
  name        = "root"
  description = "stack for managing GitHub Actions workflows"
  id          = "da09c5ab-20bb-4856-a074-a4358a7a536e"
}
