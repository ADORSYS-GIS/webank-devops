variable "availability_zones" {
  default = ["eu-central-1a", "eu-central-1b"]
}

variable "cidr_blocks" {
  default = {
    private_1 = "10.0.0.0/19"
    private_2 = "10.0.32.0/19"
    public_1  = "10.0.64.0/19"
    public_2  = "10.0.96.0/19"
  }
}
