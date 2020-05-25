# A User needs to be created with ACCESS KEY and SECRET KEY and added here
variable AWS_ACCESS_KEY_ID {
  default = "******************"
}

variable AWS_SECRET_ACCESS_KEY {
  default = "******************"
}

# Get your region from the AWS console
# EC2 -> Bottom of screen. It will have the Availability Zones there too which will be needed below
variable region {
  default = "us-west-2"
}

# Can go into multi AZ if need be, use the following:
/*
variable az {
  type    = "list"
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}
*/
variable az {
  default = "us-west-2a"
}

# Your name for the VPC. Will show in AWS Console as this
variable vpc_name {
  default = "Main_VPC"
}

# VPC CIDR range. Should be assigned to you by AWS.
# /16 means the 0.0 can be any number from 0 to 255
variable vpc_CIDR {
  default = "172.31.0.0/16"
}

# CIDR range for Public
# /24 means only the last .0 will range from 0 to 255
variable public_CIDR {
  default = "172.31.0.0/24"
}

# /24, as above, not we have put 1.0/24
variable private_CIDR {
  default = "172.31.1.0/24"
}

# key_pair_name needs to be created in AWS Console
variable key_pair_name {
  default = "Crans_key"
}

# Copy contents of above key here so one machine can SSH into the other
variable public_key {
  type = "string"

  default = <<EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAqYRKnib9euxNSay9q90ZaVXhHF6d4sXVdKI76iRugMGu2Ei/K9lvhl/KkuST
JBPP98f+mMvESgBlovXYl7OLTz62cJdBofnufdUQpPmg16Q/Ztz2VAwZDwHl8aB54HOrmwCtLcIr
hT3IkfzxnQpo+vca3NL+sOP2l9iI6c3UkhtgZy73CrcXx9dxzJoNrKoTvuXW6cG/XD6Ks6k5DjY8
3IGK6FpjK3nz9DiSqP3K6//Uf/dnNxRrl8W63T+GpkSn7l5j/PQhU73KP1OjZ19Mi7uf0s2ZEwwx
ZQVuzw76I7ACaAjAQgUxuyexz7lJ2xbjpeBymRjXf2hmacT/WGI0fwIDAQABAoIBAFuRS2E8vIXO
6TzX46jXiOd+bVgOwAiERvZ2wBiNT2ebt9+7BBEipfyW9+z7LYQ6c4dr79oHj+NNbZlmZXYklSbc
QF53RgvB3xL3qcMD2N9DKMBesWzbEBosM1KfFdaphNP4vJNQJIQXyKUbVkQ3IFgYbNlF3DAfI9AI
NoTdG2tEHjttO+zeG4xqrk3+Rbe+IUf+toFlF52PdP+/DJzYKGo/eHjHPPcQh71DZLihC+Qfgp3K
rUCnrfTj3Vo9oYMUxrskDCWOfhFHb7PzUKrJYtjhax8KJk2dlM9aRtUtRzEOq+tAg80jMsaKITzJ
8jd2N591YPc1rQVzNIBNLw2vRJkCgYEA5yg3vz3FeeXKdVIfMJW98+B5gHuDHlUbsNGUfrWDjTl4
hGQ09R296D67vbZcdckJWNVVtlSAUIN1Rne1dMkMSug2x7vKls5lgPbASttizuq2/BVWGHQLh7+5
hJFwUDNkCNLuhfOLb+ACQFCsuZm+7ZlHp/uOEeknJT1wXoVI8+sCgYEAu7wssvkMT+rI3j8E12uE
S548rckcS0mKuClW0+6bds1VLoTI4GqlzaLDtQy8w84inHV6e1dUndk2iu3UjirXHczavPcWCI1N
k56uHLhuKDWX3yDpWgV65lbvo/vqBvREkBkaFwi8VJkjb0MqC8eXj5xuGBEpLLpcHMueodSqYL0C
gYANVu7QpHnu7OngF1shbKLHnh6k4XvRlkvAyndtUIBE+BoSWc4MjyjUbDpdWla/nVhivfzyRrIY
810jMelQ0gFZmUkAAcBRL5v/8z1plHuBQV5J8dlEE/5OWSwVkGcQ2cZeE/4b0NAtJpo6p+0v0MWJ
5JyT/xpVwkS2C3OeoMZy/QKBgBFlgZrgGzT4o758hn1T2EGNmz/baATN/s3L/uDKtptOsbsK0PaC
y3R/xbTsRj26x1hKRpxRXmT2MOi020KFU8POLOLf3qnSNkMcrDO7H3IYbUde7GDMKzRXEAPZHzmf
vw6/VLyXsaQBQNhZl/bZewDy1Pzj8jXT2x9L+xox88vdAoGBAKIMKjUhuR6IJOThxHLuEI4OCTYq
GWa6oiPgaZh7nqKJ4dFLFul4k6RSNqLfSEvTdrZAKTHTtUDW72OjWth8RObu57GfKtukcnVdoc6V
q4e3dH+XFqypWvNjWpbAJAqwehYi2aGuyF1C8alayiftn5EBz75sOOf/aVuYjEFncLKa
-----END RSA PRIVATE KEY-----
EOF
}

# Keep at t2.micro for AWS free tier
variable instance_type {
  default = "t2.micro"
}
