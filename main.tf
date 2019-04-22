variable "reg" {}
variable "key" {}
variable "credentials_file" {}
variable "prof" {}
variable "port" {}
variable "my_ami" {
        type                    = "map"
        description             = "I added eu-central-1 - Frankfurt,ami-c86c3f23 - centos and eu-west-3 - Paris,ami-0cfbf4f6db41068ac - amazon linux"
}


provider "aws" {
	region 			= "${var.reg}"
	shared_credentials_file = "${var.credentials_file}"
	profile			= "${var.prof}"
}

resource "aws_instance" "my_ter_inst" {
	ami			= "${lookup(var.my_ami,var.reg)}"
	instance_type		= "t2.micro"
	key_name 		= "${var.key}"
	vpc_security_group_ids  = ["${aws_security_group.aaaaa.id}"]
	tags {
		Name = "Web-TER-server"
	}
	user_data = <<-EOF
		    #!/bin/bash
		    sudo yum install httpd -y
		    sudo yum install mc -y
		    echo "Welcom to my Web-server created by Terraform" > /var/www/html/index.html
		    service httpd start
		    EOF

	provisioner "local-exec" {
            command = "echo ${aws_instance.my_ter_inst.public_ip} >> /var/www/html/index.html"
	}
	provisioner "local-exec" {
            command = "echo ${aws_instance.my_ter_inst.public_dns} >> /var/www/html/index.html"
        }
	provisioner "local-exec" {
            command = "echo ${aws_instance.my_ter_inst.id} >> /var/www/html/index.html"
        }
	provisioner "local-exec" {
            command = "echo ${aws_instance.my_ter_inst.public_ip} > ip_address.txt"
        }

}
resource "aws_security_group" "aaaaa" {
 	name			 = "ADD_SSH and Intenet(to outside)"
	
	ingress {
    		from_port 	 = "${var.port}"
    		to_port 	 = "${var.port}"
    		protocol 	 = "tcp"
    		cidr_blocks 	 = ["0.0.0.0/0"]
		}
	ingress {
                from_port        = 80
                to_port          = 80
                protocol         = "tcp"
                cidr_blocks      = ["0.0.0.0/0"]
		}
	egress {
		from_port	 = "0"	
		to_port		 = "0"
		protocol 	 = "-1"
		cidr_blocks	 = ["0.0.0.0/0"]
 		}	
}
output "public_ip" {
	value			 = "${aws_instance.my_ter_inst.public_ip}"
}
output "public_dns" {
        value                    = "${aws_instance.my_ter_inst.public_dns}"
}
output "instance_id" {
        value                    = "${aws_instance.my_ter_inst.id}"
}

