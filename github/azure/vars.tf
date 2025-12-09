variable "owner" {
  description = "Name of the Github Organization to create repositories/teams within it."
  type        = string
  default     = ""
}

variable "github_repos" {
  description = "Map of repositories with their respective properties"
  type = map(object({
    name                            = string
    team_name                       = string
    visibility                      = optional(string)
    default_branch                  = optional(string)
    enable_required_status_checks   = optional(bool)
    required_status_checks_contexts = optional(list(string))
    dismiss_stale_reviews           = optional(bool)
    restrict_dismissals             = optional(bool)
    dismissal_restrictions          = optional(list(string))
    pr_review_count                 = optional(number)
    secrets                         = list(string)
  }))
  default = {}
}

variable "github_teams" {
  description = "Map of teams with their respective users who can have required access on particular repo"
  type = map(object({
    admins  = list(string)
    editors = list(string)
    viewers = list(string)
  }))
  default = {}
}

variable "is_enterprise" {
  description = "Flag to indicate whether the GitHub organization is enterprise or free"
  type        = bool
  default     = false
}

variable "organization_secrets" {
  description = "Secrets to be created at organization level"
  type        = list(string)
  default     = []
}

variable "resource_group_name" {
  description = "The Azure Resource Group name in which all resources are created."
  type        = string
}