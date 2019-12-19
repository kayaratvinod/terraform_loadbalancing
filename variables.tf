# variables.tf
variable "region" {
     default = "us-east-1"
}
variable "availabilityZone1" {
     default = "us-east-2a"
}
variable "availabilityZone2" {
     default = "us-east-2b"
}
variable "availabilityZone3" {
     default = "us-east-2c"
}
variable "availabilityZone4" {
     default = "us-east-2d"
}
variable "instanceTenancy" {
    default = "default"
}
variable "dnsSupport" {
    default = true
}
variable "dnsHostNames" {
    default = true
}
variable "vpcCIDRblock" {
    default = "10.0.0.0/16"
}
variable "public1subnetCIDRblock" {
    default = "10.0.1.0/24"
}
variable "public2subnetCIDRblock" {
    default = "10.0.2.0/24"
}
variable "private1subnetCIDRblock" {
    default = "10.0.3.0/24"
}
variable "private2subnetCIDRblock" {
    default = "10.0.4.0/24"
}
variable "destinationCIDRblock" {
    default = "0.0.0.0/0"
}
variable "ingressCIDRblock" {
    type = list
    default = [ "0.0.0.0/0" ]
}
variable "egressCIDRblock" {
    type = list
    default = [ "0.0.0.0/0" ]
}
variable "mapPublicIP" {
    default = true
}
variable "mapNoPublicIP" {
    default = false
}
variable "key_name" {
    default = "vinod"
}
# end of variables.tf