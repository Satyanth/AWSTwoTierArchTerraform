variable "public_CIDR_1" {
  description = "CIDR Block for public subnet"
  type        = string
  default     = "10.10.1.0/24"
}
variable "public_CIDR_2" {
  description = "CIDR Block for public subnet"
  type        = string
  default     = "10.10.2.0/24"
}
variable "private_CIDR_1" {
  description = "CIDR Block for private subnet"
  type        = string
  default     = "10.10.3.0/24"
}
variable "private_CIDR_2" {
  description = "CIDR Block for private subnet"
  type        = string
  default     = "10.10.4.0/24"
}