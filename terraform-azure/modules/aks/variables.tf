variable "resource_group_name" {}
variable "location" {}
variable "cluster_name" {}
variable "node_count" {}
variable "admin_group_object_ids" {
  type = list(string)
}
variable "subnet_id" {
  description = "The ID of the subnet to deploy the AKS cluster into"
  type = string
}


