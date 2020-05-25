output "Latest RHEL AMI ID" {
  value = "${data.aws_ami.latest_rhel.id}"
}

output "Private EC2 IP" {
  value = "${aws_instance.private_machine.private_ip}"
}

output "Bastion EC2 Private IP" {
  value = "${aws_instance.public_machine.private_ip}"
}

output "Bastion EC2 Public IP (Please wait 5 mins for user data to run)" {
  value = "${aws_instance.public_machine.public_ip}"
}
