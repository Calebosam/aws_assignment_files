# Deploy to EC2 and S3

## S3 Configs

1. Create a bucket with a unique name 
2. Enable Bucket hosting bucket properties tab

1. Update thee Bucket Policy for your bucket in the permissions tab with the following:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicRead",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::bucket-name/*"
        }
    ]
}
```

## EC2 Configs

### Launch and EC2 Instance with an ubuntu AMI and with the User data below:

```bash
#! /bin/bash

sudo apt update 
sudo apt install nginx -y
sudo apt install unzip -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

```

### Modify the IAM role on the EC2 instance with a role which has S3 access to the Bucket.

If you need to create a role, follow the steps bleow:

1. Go to the IAM console
2. Click on Roles and select Create New Role
3. In step 1 of the Role creation select AWS Service as the **Trusted entity type and EC2 as the service or use case and click next.**
4. In step 2, the policy name [AmazonS3FullAccess](https://us-east-1.console.aws.amazon.com/iam/home?region=eu-west-1#/policies/details/arn%3Aaws%3Aiam%3A%3Aaws%3Apolicy%2FAmazonS3FullAccess) and click next
5. In step 3. give the role a name and save.

### Copy the bash script below to the instance by creating a file  with name `deploy.sh` on the instance after ssh-ing on it

**`*Update the Variables as needed...*`** 

```bash
#! /bin/bash

# Variables
BUCKET_NAME="assignment-bucket-09"
PROJECT_DIR="/home/projects/assignment_files"
PROJECT_PARENT_DIR="/home/projects"
PROJECT_SRC="https://github.com/3rdsenin/assignment_files.git"
BUCKET_iNDEX="https://assignment-bucket-09.s3.eu-west-1.amazonaws.com/index.html"

deploy_app() {
  echo "Deploying to S3"
  aws s3 cp "$PROJECT_DIR" "s3://$BUCKET_NAME" --recursive --exclude "$PROJECT_DIR/.git/*"
  echo "Deploying to EC2"
  sudo cp -r * /var/www/html/
  echo "Application available at $BUCKET_iNDEX OR http://$(curl icanhazip.com)"
}

if [ -d "$PROJECT_DIR" ]; then
  echo "Folder exists, Pulling new changes..."
  cd "$PROJECT_DIR"
  sudo git pull origin main
  deploy_app
else
  sudo mkdir -p "$PROJECT_PARENT_DIR"
  echo "Folder created"
  cd "$PROJECT_PARENT_DIR"
  sudo git clone "$PROJECT_SRC"
  cd "$PROJECT_DIR"
  deploy_app
fi

```

Change the permission of the bash script with 

```bash
sudo chmod +x deploy.sh
```

Run the bash script 

```bash
./deploy.sh
```