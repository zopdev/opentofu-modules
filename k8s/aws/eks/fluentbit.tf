locals {
  fluent_bit_enable             = var.fluent_bit != null ? (var.fluent_bit.enable != null ? var.fluent_bit.enable : false) : false
  fluent_bit_cloud_watch_enable = var.fluent_bit != null ? (var.fluent_bit.cloud_watch_enable != null ? var.fluent_bit.cloud_watch_enable : false) : false
  fluent_bit_loki               = local.fluent_bit_enable ? (var.fluent_bit.loki != null ? var.fluent_bit.loki : []) : []
  fluent_bit_http               = local.fluent_bit_enable ? (var.fluent_bit.http != null ? var.fluent_bit.http : []) : []
  fluent_bit_splunk             = local.fluent_bit_enable ? (var.fluent_bit.splunk != null ? var.fluent_bit.splunk : []) : []
  fluent_bit_datadog            = local.fluent_bit_enable ? (var.fluent_bit.datadog != null ? var.fluent_bit.datadog : []) : []
  fluent_bit_newrelic           = local.fluent_bit_enable ? (var.fluent_bit.new_relic != null ? var.fluent_bit.new_relic : []) : []
  fluent_bit_slack              = local.fluent_bit_enable ? (var.fluent_bit.slack != null ? var.fluent_bit.slack : []) : []


  fluent_bit_loki_outputs = concat([
    for k, v in local.fluent_bit_loki : {
      host      = v.host
      tenant_id = v.tenant_id != null ? v.tenant_id : ""
      labels    = v.labels
      port      = v.port != null ? v.port : 3100
      tls       = v.tls != null ? v.tls : "On"
    } if length(local.fluent_bit_loki) > 0
    ], local.enable_loki ? [{
      host      = "loki-distributor.loki"
      tenant_id = random_uuid.grafana_standard_datasource_header_value.result
      labels    = "namespace=$(kubernetes['namespace_name']),pod=$(kubernetes['pod_name']),service=$(kubernetes['container_name']),cluster=${local.cluster_name}"
      port      = 3100
      tls       = "Off"
  }] : [])

  fluent_bit_http_outputs = [
    for k, v in local.fluent_bit_http : {
      host       = v.host
      port       = v.port != null ? v.port : 80
      uri        = v.uri != null ? v.uri : "/"
      headers    = v.headers != null ? v.headers : []
      tls        = v.tls != null ? v.tls : "Off"
      tls_verify = v.tls_verify != null ? v.tls_verify : "On"
    } if length(local.fluent_bit_http) > 0
  ]

  fluent_bit_splunk_outputs = [
    for k, v in local.fluent_bit_splunk : {
      host       = v.host
      token      = v.token
      port       = v.port != null ? v.port : 8088
      tls        = v.tls != null ? v.tls : "Off"
      tls_verify = v.tls_verify != null ? v.tls_verify : "On"
    } if length(local.fluent_bit_splunk) > 0
  ]

  fluent_bit_datadog_outputs = [
    for k, v in local.fluent_bit_datadog : {
      host     = v.host
      api_key  = v.api_key
      tls      = v.tls != null ? v.tls : "On"
      compress = v.compress != null ? v.compress : "gzip"
    } if length(local.fluent_bit_datadog) > 0
  ]

  fluent_bit_newrelic_outputs = [
    for k, v in local.fluent_bit_newrelic : {
      host     = v.host != null ? v.host : "https://log-api.eu.newrelic.com/log/v1"
      api_key  = v.api_key
      compress = v.compress != null ? v.compress : "gzip"
    } if length(local.fluent_bit_newrelic) > 0
  ]

  fluent_bit_slack_outputs = [
    for k, v in local.fluent_bit_slack : {
      webhook = v.webhook
    } if length(local.fluent_bit_slack) > 0
  ]

}

resource "aws_iam_policy" "fluent_bit_policy" {
  name_prefix = "${local.cluster_name}-fluent-bit-cloud-watch"
  description = "EKS fluent-bit cloudwatch policy for cluster ${local.cluster_name}"
  policy      = data.aws_iam_policy_document.fluent_bit_policy.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSCloudWatchLogsPolicy" {
  policy_arn = aws_iam_policy.fluent_bit_policy.arn
  role       = module.eks.iam_role_name
}

data "aws_iam_policy_document" "fluent_bit_policy" {
  statement {
    sid    = "CloudWatchAgentServerPolicy"
    effect = "Allow"

    actions = [
      "cloudwatch:PutMetricData",
      "ec2:DescribeVolumes",
      "ec2:DescribeTags",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:PutRetentionPolicy",
      "logs:DescribeLogGroups",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
    ]

    resources = ["arn:aws:logs:${var.app_region}:${data.aws_caller_identity.current.account_id}:log-group:/apps/${local.cluster_name}/*"]
  }

  statement {
    sid    = "GetParameter"
    effect = "Allow"

    actions = [
      "ssm:GetParameter"
    ]

    resources = ["arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"]
  }
}

data "template_file" "fluent-bit" {
  count    = local.fluent_bit_enable ? 1 : 0
  template = file("./templates/fluent-bit-values.yaml")
  vars = {
    "CLUSTER_NAME" = local.cluster_name
    "AWS_REGION"   = var.app_region
    "TAGS"         = join(",", [for key, value in local.common_tags : "${key}=${value}"])

    "HTTP_SERVER" = "On"
    "HTTP_PORT"   = "2020"

    "READ_FROM_HEAD" = "Off"
    "READ_FROM_TAIL" = "On"

    fluent_bit_cloud_watch_enable = local.fluent_bit_cloud_watch_enable
    fluent_bit_loki_outputs       = jsonencode(local.fluent_bit_loki_outputs)
    fluent_bit_http_outputs       = jsonencode(local.fluent_bit_http_outputs)
    fluent_bit_splunk_outputs     = jsonencode(local.fluent_bit_splunk_outputs)
    fluent_bit_datadog_outputs    = jsonencode(local.fluent_bit_datadog_outputs)
    fluent_bit_newrelic_outputs   = jsonencode(local.fluent_bit_newrelic_outputs)
    fluent_bit_slack_outputs      = jsonencode(local.fluent_bit_slack_outputs)
  }
}

resource "helm_release" "fluntbit-config" {
  count      = local.fluent_bit_enable ? 1 : 0
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  name       = "fluent-bit"
  version    = "0.36.0"
  namespace  = kubernetes_namespace.monitoring.metadata.0.name

  values = [
    data.template_file.fluent-bit[0].rendered
  ]
  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

