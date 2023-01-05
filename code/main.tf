data "aws_route53_zone" "zone_id" {
  name = var.zone
}

data "http" "ipv4" {
  url = "https://api.ipify.org"
}

data "http" "ipv6" {
  url = "https://api64.ipify.org"
}

module "records_ipv4" {
  source   = "./aws_route53_record"
  for_each = toset(var.subdomains)

  zone_id = data.aws_route53_zone.zone_id.zone_id
  zone    = var.zone
  name    = each.key
  records = [data.http.ipv4.response_body]
}

module "records_ipv6" {
  source   = "./aws_route53_record"
  for_each = toset(var.subdomains)

  zone_id = data.aws_route53_zone.zone_id.zone_id
  zone    = var.zone
  name    = each.key
  type    = "AAAA"
  records = [data.http.ipv6.response_body]
}
