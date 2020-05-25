#!/bin/bash

# Place the Private Key into the id_rsa file
echo "${public_key}" >> /home/ec2-user/.ssh/id_rsa
# Check owner of file in case it doesn't exist
chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa
# chmod 600 the file
chmod 600 /home/ec2-user/.ssh/id_rsa
