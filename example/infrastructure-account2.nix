# Terranix configuration for AWS Account 2 (Development)
# This gets compiled to config.tf.json and applied by OpenTofu
# Credentials: AWS_ACCOUNT2_ACCESS_KEY_ID, AWS_ACCOUNT2_SECRET_ACCESS_KEY
{
  # AWS Provider configuration for Account 2
  provider.aws = {
    region = "us-west-2";  # Different region for dev account
    # Credentials come from environment variables
    access_key = "\${var.aws_access_key}";
    secret_key = "\${var.aws_secret_key}";
  };

  # Variables for AWS credentials
  variable.aws_access_key = {
    description = "AWS Access Key for Account 2";
    type = "string";
    sensitive = true;
  };

  variable.aws_secret_key = {
    description = "AWS Secret Key for Account 2";
    type = "string";
    sensitive = true;
  };

  # Variables for customization
  variable.instance_type = {
    description = "EC2 instance type";
    default = "t3.micro";
  };

  variable.ssh_public_key = {
    description = "SSH public key for instance access";
    type = "string";
  };

  # Data source: Latest NixOS AMI
  data.aws_ami.nixos = {
    most_recent = true;
    owners = [ "427812963091" ];  # NixOS official AMI owner

    filter = [
      {
        name = "name";
        values = [ "nixos/24.05*" ];
      }
      {
        name = "architecture";
        values = [ "x86_64" ];
      }
    ];
  };

  # SSH Key Pair
  resource.aws_key_pair.deployer = {
    key_name = "inframan-account2-deployer";
    public_key = "\${var.ssh_public_key}";
  };

  # Security Group allowing SSH and HTTP/HTTPS
  resource.aws_security_group.main = {
    name = "inframan-account2-sg";
    description = "Security group for inframan-managed instance (Account 2)";

    ingress = [
      {
        description = "SSH";
        from_port = 22;
        to_port = 22;
        protocol = "tcp";
        cidr_blocks = [ "0.0.0.0/0" ];
        ipv6_cidr_blocks = [];
        prefix_list_ids = [];
        security_groups = [];
        self = false;
      }
      {
        description = "HTTP";
        from_port = 80;
        to_port = 80;
        protocol = "tcp";
        cidr_blocks = [ "0.0.0.0/0" ];
        ipv6_cidr_blocks = [];
        prefix_list_ids = [];
        security_groups = [];
        self = false;
      }
      {
        description = "HTTPS";
        from_port = 443;
        to_port = 443;
        protocol = "tcp";
        cidr_blocks = [ "0.0.0.0/0" ];
        ipv6_cidr_blocks = [];
        prefix_list_ids = [];
        security_groups = [];
        self = false;
      }
    ];

    egress = [
      {
        description = "Allow all outbound";
        from_port = 0;
        to_port = 0;
        protocol = "-1";
        cidr_blocks = [ "0.0.0.0/0" ];
        ipv6_cidr_blocks = [];
        prefix_list_ids = [];
        security_groups = [];
        self = false;
      }
    ];

    tags = {
      Name = "inframan-account2-sg";
      Environment = "development";
    };
  };

  # EC2 Instance
  resource.aws_instance.main = {
    ami = "\${data.aws_ami.nixos.id}";
    instance_type = "\${var.instance_type}";
    key_name = "\${aws_key_pair.deployer.key_name}";
    vpc_security_group_ids = [ "\${aws_security_group.main.id}" ];

    root_block_device = {
      volume_size = 20;
      volume_type = "gp3";
    };

    tags = {
      Name = "inframan-account2-instance";
      ManagedBy = "inframan";
      Environment = "development";
    };
  };

  # Output the public IP - this is what inframan reads for deployment
  output.public_ip = {
    description = "Public IP of the instance";
    value = "\${aws_instance.main.public_ip}";
  };

  output.instance_id = {
    description = "Instance ID";
    value = "\${aws_instance.main.id}";
  };
}

