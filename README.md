# Terraform AWS Web Server - Single File Solution

This is a complete, self-contained Terraform configuration in a single file that provisions a functional web server on AWS.

## 📋 What You Need

1. **AWS Account** with access credentials
2. **Terraform** installed (version 1.0+)
3. **AWS CLI** configured (optional but recommended)

## 🚀 Quick Setup

### Step 1: Configure AWS Credentials

Choose one method:

**Option A: AWS CLI**
```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and region
```

**Option B: Environment Variables**
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### Step 2: Create Your Project

```bash
# Create a new directory
mkdir terraform-webserver
cd terraform-webserver

# Create the main.tf file and paste the Terraform code into it
# IMPORTANT: Edit line 104 in main.tf to replace "John Doe" with YOUR FULL NAME
```

### Step 3: Deploy

```bash
# Initialize Terraform
terraform init

# Preview what will be created
terraform plan

# Create the infrastructure
terraform apply
# Type 'yes' when prompted
```

### Step 4: Access Your Website

After 2-3 minutes, Terraform will display outputs like:
```
Outputs:

public_ip = "54.123.456.789"
website_url = "http://54.123.456.789"
```

**Open the `website_url` in your browser!**

## 🎯 What Gets Created

- **VPC**: Virtual Private Cloud (10.0.0.0/16)
- **Subnet**: Public subnet with internet access
- **Internet Gateway**: For public connectivity
- **Security Group**: Allows HTTP (80) and SSH (22)
- **EC2 Instance**: t2.micro running Amazon Linux 2023
- **Web Server**: Apache serving your custom HTML page

## 💰 Cost

- **t2.micro** instance is Free Tier eligible
- If within Free Tier: **FREE** or **<$1/month**
- Otherwise: ~$8-10/month

## 🛑 Cleanup (Important!)

To avoid charges, destroy all resources when done:

```bash
terraform destroy
# Type 'yes' when prompted
```

## 🔧 Customization

### Change Your Name
Edit line 104 in `main.tf`:
```html
<h1>Your Full Name Here</h1>
```

### Change Region
Edit line 12 in `main.tf`:
```hcl
region = "us-west-2"  # Change to your preferred region
```

### Change Instance Type
Edit line 134 in `main.tf`:
```hcl
instance_type = "t3.micro"  # Or any other instance type
```

## 📁 Single File Structure

Everything is in **one file**: `main.tf`

This includes:
- Provider configuration
- Networking (VPC, subnet, IGW, routes)
- Security group
- EC2 instance with user data
- Outputs

## ❓ Troubleshooting

**Website not loading?**
- Wait 2-3 minutes after `terraform apply` completes
- The user data script needs time to install Apache
- Check the security group allows port 80

**Terraform errors?**
- Verify AWS credentials are configured
- Ensure you have proper IAM permissions
- Check you're using Terraform 1.0+

**Want to see what's happening?**
```bash
# SSH into the instance (requires key pair setup)
ssh ec2-user@<public-ip>

# Check Apache status
sudo systemctl status httpd
```

## 🔒 Security Notes

⚠️ This is a demo setup. For production:
- Restrict SSH access to your IP only
- Use HTTPS with SSL/TLS
- Implement proper backup strategies
- Use IAM roles instead of access keys
- Enable CloudWatch monitoring

## 📝 Git Repository Setup

```bash
# Initialize git
git init

# Create .gitignore
cat > .gitignore <<EOL
**/.terraform/*
*.tfstate
*.tfstate.*
crash.log
.DS_Store
*.pem
EOL

# Add and commit
git add main.tf README.md .gitignore
git commit -m "Initial commit: Terraform AWS web server"

# Push to GitHub (create repo first on GitHub)
git remote add origin https://github.com/yourusername/terraform-webserver.git
git branch -M main
git push -u origin main
```

## ✅ Verification Checklist

- [ ] AWS credentials configured
- [ ] Terraform installed
- [ ] Changed "John Doe" to your name in main.tf
- [ ] Ran `terraform init`
- [ ] Ran `terraform apply` successfully
- [ ] Website loads in browser
- [ ] Displays your full name
- [ ] Ran `terraform destroy` when done (to avoid charges)

## 📞 Support

If you encounter issues:
1. Check AWS service limits in your region
2. Verify your IAM user has EC2, VPC permissions
3. Try a different AWS region
4. Check AWS Free Tier status

## 📄 License

MIT License - Free to use and modify

---

**Made with Terraform** 🚀