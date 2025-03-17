locals {
  labels = {}

  fallback_nameserver = ["1.1.1.1", "8.8.8.8", "9.9.9.9"]

  any_feature_enabled = anytrue([for feature, status in var.features : status])
}
