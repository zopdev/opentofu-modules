# Github
GitHub is a module which contains terraform files within it to create the GitHub repositories in particular GitHub organisation,
and provide the required access to the users by creating teams to GitHub repositories based on the given inputs.

## Values

| Inputs               | Type         | Required/Optional | <div style="width:430px">Description</div>                                                                          | Default                |
|----------------------|--------------|-------------------|---------------------------------------------------------------------------------------------------------------------|------------------------|
| github_base_url      | string       | Optional          | The base URL of the GitHub API                                                                                      | `"https://github.com"` |
| github_repos         | Map(object)  | Required          | Map of repositories with their respective properties (For more info check below)                                    | `{}`                   |
| github_teams         | Map(object)  | Required          | Map of teams with their respective users who can have required access on particular repo(For more info check below) | `{}`                   |
| is_enterprise        | bool         | Optional          | Flag to indicate whether the GitHub organization is enterprise or free                                              | `false`                |
| organization_secrets | list(string) | Required          | Secrets to be created at organization level                                                                         | `[]`                   |
| owner                | string       | Required          | Name of the Github Organization to create repositories/teams within it                                              | `""`                   |
| resource_group_name         | string       | Required          | The Azure Resource Group name in which all resources are created.                                                           | `""`                   |

#### github_repos
| Inputs         | Type         | Required/Optional | <div style="width:400px">Description</div>            | Default   |
|----------------|--------------|-------------------|-------------------------------------------------------|-----------|
| default_branch | string       | Optional          | Default branch in the github repo                     | `main`    |
| name           | string       | Required          | Name of the repo                                      |           |
| team_name      | string       | Required          | Github team name that provide the access to the users | `""`      |
| secrets        | list(string) | Required          | Secrets to be created at repo level                   | `[]`      |
| visibility     | string       | Optional          | Visibility of the github repo(`public` or `private`)  | `private` |


#### github_teams
| Inputs  | Type         | Required/Optional | <div style="width:400px">Description</div>           | Default |
|---------|--------------|-------------------|------------------------------------------------------|---------|
| admins  | list(string) | Required          | List of users who can have admin access in the team  | `null`  |
| editors | list(string) | Required          | List of users who can have editor access in the team | `null`  |
| viewers | list(string) | Required          | List of users who can have viewer access in the team | `null`  |