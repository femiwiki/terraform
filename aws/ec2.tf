resource "aws_key_pair" "femiwiki" {
  key_name   = "femiwiki-2018-09-15"
  public_key = file("res/femiwiki_rsa.pub")
}

resource "aws_instance" "mediawiki" {
  ebs_optimized        = true
  ami                  = "ami-02f64686a16f77fbd"
  instance_type        = "t3a.micro"
  key_name             = aws_key_pair.femiwiki.key_name
  monitoring           = false
  iam_instance_profile = aws_iam_instance_profile.mediawiki.name

  vpc_security_group_ids = [
    aws_default_security_group.default.id,
    aws_security_group.mediawiki.id,
  ]

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 0
    volume_size           = 16
    volume_type           = "standard"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "mediawiki"
  }

  volume_tags = {
    Name = "mediawiki"
  }

  user_data = <<EOF
#!/bin/bash
set -euo pipefail; IFS=$'\n\t'

# Enable verbose mode
set -x

sudo -u ec2-user git clone https://github.com/femiwiki/mediawiki.git /home/ec2-user/mediawiki/
# TODO: Download seceret from S3
sudo -u ec2-user cp /home/ec2-user/mediawiki/configs/secret.php.example /home/ec2-user/mediawiki/configs/secret.php
docker swarm init
# docker stack deploy --prune -c /home/ec2-user/mediawiki/production.yml mediawiki
EOF
}

resource "aws_eip" "mediawiki" {
  instance = aws_instance.mediawiki.id
  vpc      = true
}

resource "aws_instance" "database_bots" {
  ebs_optimized           = true
  ami                     = "ami-0019c8208fd95e551"
  instance_type           = "t3.nano"
  key_name                = aws_key_pair.femiwiki.key_name
  monitoring              = false
  iam_instance_profile    = aws_iam_instance_profile.upload_backup.name
  disable_api_termination = true
  vpc_security_group_ids = [
    aws_default_security_group.default.id,
    aws_security_group.db.id,
  ]

  root_block_device {
    delete_on_termination = false
    encrypted             = false
    iops                  = 100
    volume_size           = 16
    volume_type           = "gp2"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "database+bots"
  }

  volume_tags = {
    Name = "database+bots"
  }

  # # 이 부분을 주석 해제하면 인스턴스가 Replacement 됩니다.
  # user_data = <<EOF
  # #!/bin/bash
  # set -euo pipefail; IFS=$'\n\t'

  # # Enable verbose mode
  # set -x

  # sudo -u ec2-user git clone https://github.com/femiwiki/database.git /home/ec2-user/swarm/
  # # TODO: Download SQL dump from S3
  # docker swarm init
  # docker stack deploy --prune -c /home/ec2-user/swarm/database.yml database
  # docker stack deploy --prune -c /home/ec2-user/swarm/memcached.yml memcached
  # docker stack deploy --prune -c /home/ec2-user/swarm/bots.yml botse
  # EOF
}