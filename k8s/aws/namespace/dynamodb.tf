data "aws_caller_identity" "current" {}


 module "dynamodb_table" {
  source         = "terraform-aws-modules/dynamodb-table/aws"

  for_each       = {  for k, v in var.dynamo_db : k => v }
  name           = "${local.cluster_name}-${var.namespace}-${each.key}-dynamodb-table"
  billing_mode   = each.value.billing_mode
  read_capacity  = each.value.read_capacity
  write_capacity = each.value.write_capacity
  hash_key       = each.value.hash_key
  range_key      = each.value.range_key

  attributes = [
    {
      name = each.value.hash_key
      type = each.value.hash_key_type
    },
    {
      name = each.value.range_key
      type = each.value.range_key_type
    }
  ]
  ttl_enabled = each.value.ttl_enabled
  ttl_attribute_name = each.value.ttl_attribute_name

   global_secondary_indexes = each.value.global_secondary_index != null ? each.value.global_secondary_index : []

  tags = local.common_tags
}


### policy per namespace with wild card on table arns
resource "aws_iam_policy" "policy" {

  count = length(var.dynamo_db) == 0 ? 0 : 1

  name        = "${local.cluster_name}-${var.namespace}-policy"
  description = " ${var.namespace} namespace dynamo user policy"

  policy = jsonencode({
    Version= "2012-10-17"
     Statement= [
        {
            Action= [
                "dynamodb:*"
            ],
            Effect= "Allow"
            Resource= "arn:aws:dynamodb:${var.app_region}:${data.aws_caller_identity.current.account_id}:table/${local.cluster_name}-${var.namespace}*"
        },
        {
           "Sid": "readOnly",
           "Effect": "Allow",
           "Action": [
               "dynamodb:List*",
               "dynamodb:DescribeReservedCapacity*",
               "dynamodb:DescribeLimits",
               "dynamodb:DescribeTimeToLive"
           ],
           "Resource": "*"
       }
    ]
  })

}

### iam user  per namespace to access dynamo tables
resource "aws_iam_user" "dynamo_user" {
  count = length(var.dynamo_db) == 0 ? 0 : 1

  name      =  "${local.cluster_name}-${var.namespace}-dynamo-user"
  tags      = local.common_tags
}


resource "aws_iam_user_policy_attachment" "attach" {
  count = length(var.dynamo_db) == 0 ? 0 : 1

  user       = aws_iam_user.dynamo_user[0].name
  policy_arn = aws_iam_policy.policy[0].arn
}

### creating ak and sk keys per dynamo user

resource "aws_iam_access_key" "dynamo_keys" {
  count = length(var.dynamo_db) == 0 ? 0 : 1

  user      = aws_iam_user.dynamo_user[0].name
}

# store keys of the user per name space ( two keys per user) into aws secrets
resource "aws_secretsmanager_secret" "dynamo_db_secrets" {
  count = length(var.dynamo_db) == 0 ? 0 : 1

  name       = "${local.cluster_name}-${var.namespace}-dynamo-db-secret"
  tags       =  local.common_tags
}

resource "aws_secretsmanager_secret_version" "dynamo_db_secrets" {
  count = length(var.dynamo_db) == 0 ? 0 : 1

  secret_id     = aws_secretsmanager_secret.dynamo_db_secrets[0].id
  secret_string = jsonencode({ access_key = aws_iam_access_key.dynamo_keys[0].id,
                   secret_key = aws_iam_access_key.dynamo_keys[0].secret})

}

resource "aws_secretsmanager_secret" "dynamo_user_sk" {
  count = length(var.dynamo_db) == 0 ? 0 : 1

  name       = "${local.cluster_name}-${var.namespace}-dynamo-user-secret-key"
  tags       =  local.common_tags
}

resource "aws_secretsmanager_secret_version" "dynamo_user_sk" {
  count = length(var.dynamo_db) == 0 ? 0 : 1

  secret_id     = aws_secretsmanager_secret.dynamo_user_sk[0].id
  secret_string = jsondecode(aws_secretsmanager_secret_version.dynamo_db_secrets[0].secret_string).secret_key
}