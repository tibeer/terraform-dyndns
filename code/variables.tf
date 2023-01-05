variable "zone" {
  default = "foobar.com"
}

variable "subdomains" {
  default = [
    "",  # use this for plain records
    "server1",
    "server2"
  ]
}
