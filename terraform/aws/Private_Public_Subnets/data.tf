# This generates a data item to find the latest RHEL from the AWS Console.
data "aws_ami" "latest_rhel" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-7*"]
  }
}

# Makes the User Data script usable - Public
data "template_file" "user_data_public" {
  template = "${file("user_data_public.sh")}"

  vars {
    public_key = "${var.public_key}"
    region     = "${var.region}"
    bucket     = "${aws_s3_bucket.apps_bucket.bucket}"
    private_ip = "${aws_instance.private_machine.private_ip}"
  }
}

# Makes the User Data script usable - Private
data "template_file" "user_data_private" {
  template = "${file("user_data_private.sh")}"

  vars {
    public_key = "${var.public_key}"
  }
}
