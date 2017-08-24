variable "name"       { type = "string" }
variable "region"     { type = "string" }

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

## VPC parameters
variable "private_subnet_1a" { 
    type = "string"
    description = "The Private1a CIDR block for the VPC."
    default     = "172.16.1.0/21"
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC."
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC."
  default     = []
}

variable "private_subnet_names" {
  description = "A list of private subnets names."
  default     = []
}

variable "enable_classiclink" {
  description = "A boolean flag to enable/disable ClassicLink for the VPC. Only valid in regions and accounts that support EC2 Classic. Defaults false."
  default     = "false"
}

variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  default     = true
}

variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
  default     = true
}

variable "enable_flowlog" {
  description = "A boolean flag to enable/disable flowlog for vpc."
  default     = true
}

variable "instance_tenancy" {
  type        = "string"
  description = "A tenancy option for instances launched into the VPC."
  default     = "default"
}

variable "vpc_cidr_block" {
  type        = "string"
  description = "The CIDR block for the VPC."
  default     = "172.16.0.0/21"
}

variable "azs" {
  description = "A list of Availability zones in the region"
  default     = []
}

# Nat & Route

variable "enable_nat_gateway" {
    description = "Enable NAT Gateways for each of your private networks"
    default     = false
}

variable "private_propagating_vgws" {
  description = "A list of VGWs the private route table should propagate."
  default     = []
}

variable "public_propagating_vgws" {
  description = "A list of VGWs the public route table should propagate."
  default     = []
}

variable "map_public_ip_on_launch" {
  description = "should be true if you do want to auto-assign public IP on launch"
  default     = false
}


# Flowlog

variable "flow_log_filter" {
  description = "CloudWatch subscription filter to match flow logs."
  default = "[version, account, eni, source, destination, srcport, destport, protocol, packets, bytes, windowstart, windowend, action, flowlogstatus]"
}

variable "cloudwatch_retention_in_days" {
  description = "Number of days to keep logs within the cloudwatch log_group."
  default = "7"
}