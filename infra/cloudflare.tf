provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_dns_record" "staging" {
  zone_id = var.cloudflare_zone_id
  name    = "staging.multirogue"
  content = "ghs.googlehosted.com"
  type    = "CNAME"
  ttl     = 300
  proxied = false
}

resource "cloudflare_dns_record" "production" {
  zone_id = var.cloudflare_zone_id
  name    = "multirogue"
  content = "ghs.googlehosted.com"
  type    = "CNAME"
  ttl     = 300
  proxied = false
}
