resource "github_branch_protection" "branch_protection" {
  for_each   = {for k,v in var.github_repos : k => v if var.is_enterprise || v.visibility == "public"}

  repository_id          = each.value.name
  pattern                = each.value.default_branch != null ? each.value.default_branch : "main"
  allows_deletions       = false
  allows_force_pushes    = false

  required_status_checks {
    strict                = each.value.enable_required_status_checks != null ? each.value.enable_required_status_checks : false
    contexts              = each.value.required_status_checks_contexts != null ? each.value.required_status_checks_contexts : []
  }

  required_pull_request_reviews {
    dismiss_stale_reviews  = true
    restrict_dismissals    = each.value.restrict_dismissals != null ? each.value.restrict_dismissals : true
    dismissal_restrictions = each.value.dismissal_restrictions != null ? each.value.dismissal_restrictions : []
    require_last_push_approval      = true
    required_approving_review_count = each.value.pr_review_count != null ? each.value.pr_review_count : 1
  }
}