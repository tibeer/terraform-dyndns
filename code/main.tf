data "aws_route53_zone" "zone_id" {
  name = var.zone
}

data "external" "ipv4" {
  program = ["bash", "get_ip.sh", "-4"]
}

data "external" "ipv6" {
  program = ["bash", "get_ip.sh", "-6"]
}

module "records_ipv4" {
  source   = "./aws_route53_record"
  for_each = toset(var.subdomains)

  zone_id = data.aws_route53_zone.zone_id.zone_id
  zone    = var.zone
  name    = each.key
  records = [data.external.ipv4.result["ip"]]
}

module "records_ipv6" {
  source   = "./aws_route53_record"
  for_each = toset(var.subdomains)

  zone_id = data.aws_route53_zone.zone_id.zone_id
  zone    = var.zone
  name    = each.key
  type    = "AAAA"
  records = [data.external.ipv6.result["ip"]]
}
