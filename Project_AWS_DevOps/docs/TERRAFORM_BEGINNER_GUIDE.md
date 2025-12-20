# 🎓 Terraform Complete Beginner's Guide

## Understanding Infrastructure as Code with Your AWS DevOps Project

This guide explains Terraform from scratch using real examples from your
`Project_AWS_DevOps` deployment.



## 📖 Table of Contents

1. [What is Terraform?](#what-is-terraform)
2. [Basic Terraform Syntax](#basic-terraform-syntax)
3. [Understanding main.tf](#understanding-maintf)
4. [Variables Explained](#variables-explained)
5. [Outputs Explained](#outputs-explained)
6. [Understanding Modules](#understanding-modules)
7. [Resource Dependencies](#resource-dependencies)
8. [Advanced Features](#advanced-features)
9. [Terraform Workflow](#terraform-workflow)
10. [State Management](#state-management)
11. [Project Structure](#project-structure)
12. [Quick Reference](#quick-reference)



## What is Terraform?

Terraform is a tool that lets you write **code** to create cloud infrastructure
(servers, networks, databases, etc.) instead of clicking buttons in the AWS
console. This is called **Infrastructure as Code (IaC)**.

### Why Use Terraform?

- ✅ **Repeatable** - Run the same code to create identical infrastructure
- ✅ **Version controlled** - Track changes in Git
- ✅ **Automated** - No manual clicking in AWS console
- ✅ **Easy cleanup** - Delete everything with one command
- ✅ **Multi-region** - Deploy to multiple regions easily
- ✅ **Documentation** - Your code IS your documentation

### Real-World Example from Your Project

Instead of:
1. Logging into AWS Console
2. Clicking "Create VPC"
3. Manually configuring subnets
4. Creating security groups
5. Setting up load balancers
6. ...repeat for second region

You run:
```bash
terraform apply
```

And Terraform creates **75 resources** across **2 regions** in 15 minutes!



## Basic Terraform Syntax

Everything in Terraform is organized in **blocks**:

```hcl
block_type "label" "name" {
  argument1 = value1
  argument2 = value2

  nested_block {
    setting = value
  }
}
```

### Key Block Types

| Block Type | Purpose | Example |
|------------|---------|---------|
| `terraform {}` | Terraform settings | Version requirements |
| `provider "name"` | Configure cloud provider | AWS, Azure, GCP |
| `variable "name"` | Define inputs | Make code flexible |
| `resource "type" "name"` | Create infrastructure | VPC, EC2, S3 |
| `module "name"` | Use reusable code | Call a module |
| `output "name"` | Return values | Show URLs, IDs |
| `data "type" "name"` | Query existing resources | Find AMIs |
| `locals {}` | Define calculated values | Complex expressions |



## Understanding main.tf

Your `terraform/main.tf` is the main configuration file. Let's break it down
section by section.

### A. Terraform Block (Configuration)

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

**What each part means:**

- `terraform { }` - Configuration for Terraform itself
- `required_version = ">= 1.0"` - Minimum Terraform version needed
- `required_providers` - Which cloud providers to use
- `source = "hashicorp/aws"` - Download AWS provider from HashiCorp registry
- `version = "~> 5.0"` - Use AWS provider version 5.x (allow 5.1, 5.2, but not
  6.0)

**Think of it as:** Installing the right tools before starting work.



### B. Provider Block (AWS Connection)

```hcl
provider "aws" {
  region = var.primary_region
  alias  = "primary"

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "DevOps-Team"
    }
  }
}
```

**What each part means:**

- `provider "aws"` - Configures connection to AWS
- `region = var.primary_region` - Which AWS region (reads from variables.tf)
- `alias = "primary"` - Nickname for this provider
- `default_tags` - Automatically add these labels to ALL resources

**Why use `alias`?**

Your project deploys to **2 regions** (us-east-1 and us-east-2), so you need 2
provider configurations:

```hcl
provider "aws" {
  region = "us-east-1"
  alias  = "primary"      # For main region
}

provider "aws" {
  region = "us-east-2"
  alias  = "secondary"    # For backup region
}
```

**Think of it as:** Having two AWS accounts logged in at once.



### C. Module Block (Reusable Components)

```hcl
module "primary_vpc" {
  source = "./modules/vpc"

  providers = {
    aws = aws.primary
  }

  project_name = var.project_name
  environment  = var.environment
  region       = var.primary_region
  vpc_cidr     = var.primary_vpc_cidr
  azs          = var.primary_azs
}
```

**What each part means:**

- `module "primary_vpc"` - Name you give this module instance
- `source = "./modules/vpc"` - Where to find the module code (local folder)
- `providers = { aws = aws.primary }` - Use the "primary" AWS connection
- Arguments below - Values passed to the module (like function parameters)

**Think of it as:** Calling a function:

```javascript
createVPC({
  location: "us-east-1",
  projectName: "logicworks-devops",
  cidr: "10.0.0.0/16"
})
```

The actual VPC creation code is in `./modules/vpc/` folder, so you can reuse it!



## Variables Explained

Variables make your code flexible - like function parameters.

### Variable Syntax

```hcl
variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "logicworks-devops"
}
```

**Parts explained:**

- `variable "project_name"` - Creates a variable named `project_name`
- `description` - Human-readable explanation
- `type = string` - What kind of value this accepts
- `default = "..."` - Value to use if not provided

### Variable Types

```hcl
# String (text)
variable "name" {
  type    = string
  default = "my-app"
}

# Number
variable "instance_count" {
  type    = number
  default = 2
}

# Boolean (true/false)
variable "enable_monitoring" {
  type    = bool
  default = true
}

# List (array)
variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

# Map (key-value pairs)
variable "tags" {
  type = map(string)
  default = {
    Environment = "production"
    Team        = "DevOps"
  }
}
```

### Using Variables

```hcl
# Reference a variable
name = var.project_name

# String interpolation (insert variable into text)
name = "${var.project_name}-vpc"

# Access list item
availability_zone = var.availability_zones[0]  # First item

# Access map value
environment = var.tags["Environment"]
```

### Example from Your Project

```hcl
variable "primary_azs" {
  description = "Availability zones for primary region"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
```

Used in code:
```hcl
count             = length(var.primary_azs)  # Creates 2 subnets
availability_zone = var.primary_azs[0]       # "us-east-1a"
```



## Outputs Explained

Outputs display information after Terraform creates resources.

### Output Syntax

```hcl
output "primary_alb_url" {
  description = "Primary region application URL"
  value       = "http://${module.primary_ecs.alb_dns_name}"
}
```

**Parts explained:**

- `output "primary_alb_url"` - Name of this output
- `description` - What this output shows
- `value` - The actual value to display
- `${...}` - String interpolation (insert a value)
- `module.primary_ecs.alb_dns_name` - Get DNS name from ECS module

### When You Run `terraform apply`

After deployment completes, Terraform shows:

```
Outputs:

primary_alb_url = "http://logicworks-devops-alb-us-east-1-593780670.us-east-1.elb.amazonaws.com"
secondary_alb_url = "http://logicworks-devops-alb-us-east-2-1135554901.us-east-2.elb.amazonaws.com"
primary_region = "us-east-1"
secondary_region = "us-east-2"
```

**Think of it as:** Return values from a function.

### Chaining Outputs Between Modules

Module outputs can be used as inputs to other modules:

```hcl
# VPC module outputs its VPC ID
output "vpc_id" {
  value = aws_vpc.main.id
}

# ECS module uses that VPC ID
module "primary_ecs" {
  vpc_id = module.primary_vpc.vpc_id  # Reference the output
}
```



## Understanding Modules

Modules are reusable pieces of Terraform code - like functions in programming.

### Module Structure

```
modules/ecr/
  ├── main.tf       ← Resource definitions (what to create)
  ├── variables.tf  ← Inputs (what the module needs)
  └── outputs.tf    ← Outputs (what the module returns)
```

### Example: ECR Module

**modules/ecr/main.tf** - Creates Docker registry

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_ecr_repository" "main" {
  name                 = "${var.project_name}-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-ecr"
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep only last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}
```

**modules/ecr/variables.tf** - Module inputs

```hcl
variable "project_name" {
  description = "Project name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}
```

**modules/ecr/outputs.tf** - Module outputs

```hcl
output "repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.main.repository_url
}

output "repository_arn" {
  description = "ECR repository ARN"
  value       = aws_ecr_repository.main.arn
}
```

### Using the Module

```hcl
module "primary_ecr" {
  source       = "./modules/ecr"
  project_name = "logicworks-devops"
  region       = "us-east-1"
}

# Use the module's output
output "ecr_url" {
  value = module.primary_ecr.repository_url
}
```



## Resource Dependencies

### A. Resource Block - The Core of Terraform

```hcl
resource "RESOURCE_TYPE" "LOCAL_NAME" {
  argument1 = value1
  argument2 = value2
}
```

**Real example:**

```hcl
resource "aws_ecr_repository" "main" {
  name                 = "${var.project_name}-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-ecr"
  }
}
```

**Parts explained:**

- `resource` - Keyword to create something
- `"aws_ecr_repository"` - What to create (from AWS provider docs)
- `"main"` - Your local name for this resource
- `name`, `image_tag_mutability`, etc. - Arguments specific to ECR

### B. Referencing Other Resources

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id  # Reference the VPC's ID
}
```

**Syntax for referencing:**

```
RESOURCE_TYPE.LOCAL_NAME.ATTRIBUTE
```

Examples:
- `aws_vpc.main.id` - Get VPC's ID
- `aws_ecr_repository.main.repository_url` - Get ECR's URL
- `module.primary_vpc.vpc_id` - Get output from a module

### C. Automatic Dependency Detection

Terraform automatically knows the order to create resources:

```hcl
# 1. Create VPC first
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# 2. Then create Internet Gateway (depends on VPC)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# 3. Then create route table (depends on IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}
```

**Terraform figures out:** VPC → Internet Gateway → Route Table

### D. Explicit Dependencies with `depends_on`

Sometimes you need to manually specify order:

```hcl
resource "aws_eip" "nat" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.main]
}
```

**Use when:**
- Terraform can't detect the dependency automatically
- AWS requires one resource to exist before another



## Advanced Features

### A. The `count` Meta-Argument (Creating Multiple Resources)

```hcl
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  }
}
```

**What happens:**

- `count = 2` creates **2 subnets**
- `count.index` is the current number (0, 1, 2, ...)
- Creates:
  - `aws_subnet.public[0]` - First subnet
  - `aws_subnet.public[1]` - Second subnet

**Dynamic count with list length:**

```hcl
variable "azs" {
  default = ["us-east-1a", "us-east-1b"]
}

resource "aws_subnet" "public" {
  count = length(var.azs)  # Automatically creates 2 subnets
  # ...
}
```

### B. String Interpolation

```hcl
# Simple interpolation
name = "${var.project_name}-vpc"
# Result: "logicworks-devops-vpc"

# Math operations
name = "subnet-${count.index + 1}"
# Result: "subnet-1", "subnet-2"

# Conditional
name = "${var.environment == "production" ? "prod" : "dev"}-vpc"
# Result: "prod-vpc" or "dev-vpc"
```

### C. Built-in Functions

Terraform has many built-in functions:

#### 1. `length(list)` - Count items

```hcl
length(["a", "b", "c"])  # Returns: 3
```

#### 2. `cidrsubnet(prefix, newbits, netnum)` - Calculate subnets

```hcl
cidrsubnet("10.0.0.0/16", 8, 0)   # Returns: "10.0.0.0/24"
cidrsubnet("10.0.0.0/16", 8, 1)   # Returns: "10.0.1.0/24"
cidrsubnet("10.0.0.0/16", 8, 10)  # Returns: "10.0.10.0/24"
```

**What it does:** Splits a network into smaller subnets automatically.

#### 3. `jsonencode(value)` - Convert to JSON

```hcl
policy = jsonencode({
  Version = "2012-10-17"
  Statement = [{
    Effect = "Allow"
    Action = ["s3:GetObject"]
  }]
})
```

#### 4. `concat(list1, list2)` - Merge lists

```hcl
concat(["a", "b"], ["c", "d"])  # Returns: ["a", "b", "c", "d"]
```

#### 5. `lookup(map, key, default)` - Get value from map

```hcl
lookup({name = "vpc", type = "network"}, "name", "default")  # Returns: "vpc"
```

### D. Nested Blocks

Some arguments accept nested configuration:

```hcl
resource "aws_ecr_repository" "main" {
  name = "my-app"

  image_scanning_configuration {  # Nested block
    scan_on_push = true
  }

  encryption_configuration {      # Another nested block
    encryption_type = "AES256"
  }
}
```



## Terraform Workflow

### Command Overview

```bash
# 1. Initialize - Download providers
terraform init

# 2. Validate - Check syntax
terraform validate

# 3. Format - Auto-format code
terraform fmt

# 4. Plan - Preview changes (doesn't create anything)
terraform plan

# 5. Apply - Create resources
terraform apply

# 6. Show - Display current state
terraform show

# 7. Output - Show output values
terraform output

# 8. Destroy - Delete everything
terraform destroy
```

### Detailed Workflow

#### 1. `terraform init`

**What it does:**
- Downloads provider plugins (AWS, Azure, etc.)
- Initializes backend (state storage)
- Downloads modules
- Creates `.terraform/` folder and `.terraform.lock.hcl`

**Output:**
```
Initializing the backend...
Initializing provider plugins...
- Installing hashicorp/aws v5.100.0...

Terraform has been successfully initialized!
```

**When to run:**
- First time working with project
- After adding new providers or modules
- After cloning the repository



#### 2. `terraform validate`

**What it does:**
- Checks syntax errors
- Validates configuration

**Output:**
```
Success! The configuration is valid.
```



#### 3. `terraform plan`

**What it does:**
- Reads your `.tf` files
- Compares with current AWS state
- Shows what will be created/changed/destroyed
- **DOESN'T CHANGE ANYTHING!** (safe to run)

**Output:**
```
Terraform will perform the following actions:

  # aws_vpc.main will be created
  + resource "aws_vpc" "main" {
      + cidr_block = "10.0.0.0/16"
      + id         = (known after apply)
    }

Plan: 75 to add, 0 to change, 0 to destroy.
```

**Symbols:**
- `+` - Will create
- `-` - Will destroy
- `~` - Will modify
- `-/+` - Will replace (destroy then create)



#### 4. `terraform apply`

**What it does:**
- Runs the plan
- Actually creates AWS resources
- Saves state to `terraform.tfstate`

**Output:**
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_vpc.main: Creating...
aws_vpc.main: Creation complete after 5s [id=vpc-0123456789]

Apply complete! Resources: 75 added, 0 changed, 0 destroyed.

Outputs:

primary_alb_url = "http://my-alb-123.us-east-1.elb.amazonaws.com"
```

**Auto-approve (skip confirmation):**
```bash
terraform apply -auto-approve
```



#### 5. `terraform output`

**What it does:**
- Shows output values

**Output:**
```
primary_alb_url = "http://my-alb-123.us-east-1.elb.amazonaws.com"
secondary_alb_url = "http://my-alb-456.us-east-2.elb.amazonaws.com"
```

**Get specific output:**
```bash
terraform output primary_alb_url
# Returns: "http://my-alb-123.us-east-1.elb.amazonaws.com"
```



#### 6. `terraform destroy`

**What it does:**
- Deletes ALL resources Terraform created
- **BE VERY CAREFUL!**

**Output:**
```
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure.
  This action cannot be undone.

  Enter a value: yes

aws_ecs_service.main: Destroying...
aws_vpc.main: Destroying...

Destroy complete! Resources: 75 destroyed.
```



## State Management

### What is Terraform State?

A file (`terraform.tfstate`) that tracks what Terraform created. It maps your
code to real AWS resources.

### Example State Content

```json
{
  "version": 4,
  "terraform_version": "1.0.0",
  "resources": [
    {
      "type": "aws_vpc",
      "name": "main",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "attributes": {
            "id": "vpc-0123456789abcdef0",
            "cidr_block": "10.0.0.0/16",
            "enable_dns_hostnames": true
          }
        }
      ]
    }
  ]
}
```

### Why State is Important

1. **Tracks Resources**: Knows what Terraform created
2. **Enables Updates**: Can modify existing resources
3. **Enables Deletion**: Can delete resources later
4. **Performance**: Doesn't query AWS every time
5. **Collaboration**: Team members share the same state

### State Best Practices

**❌ DON'T:**
- Edit state file manually
- Commit state file to Git (contains sensitive data)
- Delete state file accidentally

**✅ DO:**
- Back up state file
- Use remote state (S3, Terraform Cloud) for teams
- Use state locking to prevent conflicts

### Your Project's State Reset Script

When switching AWS accounts (6-hour rotation):

```bash
./scripts/reset-state.sh
```

This removes:
- `terraform.tfstate`
- `terraform.tfstate.backup`
- `tfplan`
- `.terraform.lock.hcl`

So you can deploy to a fresh AWS account.



## Project Structure

### Your Project Layout

```
terraform/
├── main.tf              ← Main configuration, calls modules
├── variables.tf         ← All input variables
├── outputs.tf           ← What to show after deployment
└── modules/             ← Reusable components
    ├── vpc/             ← Network infrastructure
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ecr/             ← Docker registry
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ecs/             ← Container orchestration
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── codecommit/      ← Git repository
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── codepipeline/    ← CI/CD pipeline
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── monitoring/      ← CloudWatch dashboards
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### Module Responsibility

| Module | What It Creates | AWS Resources |
|--------|-----------------|---------------|
| **vpc** | Network infrastructure | VPC, Subnets, Route Tables, NAT Gateways, Internet Gateway |
| **ecr** | Docker registry | ECR Repository, Lifecycle Policy |
| **ecs** | Container platform | ECS Cluster, Services, Task Definitions, Load Balancers |
| **codecommit** | Git repository | CodeCommit Repository |
| **codepipeline** | CI/CD pipeline | CodePipeline, CodeBuild, S3 Bucket, EventBridge |
| **monitoring** | Observability | CloudWatch Dashboards, Alarms, SNS Topics, Metric Filters |

### Why This Structure?

**Benefits:**
- ✅ **Modularity**: Each module has a single responsibility
- ✅ **Reusability**: Use VPC module in other projects
- ✅ **Testing**: Test each module independently
- ✅ **Organization**: Easy to find and understand code
- ✅ **Team Collaboration**: Different people work on different modules
- ✅ **Maintenance**: Update one module without affecting others



## Real Example: Complete Flow

Let's trace what happens when you deploy:

### Step 1: You Run

```bash
terraform apply
```

### Step 2: Terraform Reads main.tf

```hcl
module "primary_vpc" {
  source = "./modules/vpc"

  project_name = "logicworks-devops"
  environment  = "production"
  vpc_cidr     = "10.0.0.0/16"
  azs          = ["us-east-1a", "us-east-1b"]
  region       = "us-east-1"
}

module "primary_ecs" {
  source = "./modules/ecs"

  vpc_id              = module.primary_vpc.vpc_id
  public_subnets      = module.primary_vpc.public_subnets
  private_subnets     = module.primary_vpc.private_subnets
  ecr_repository_url  = module.primary_ecr.repository_url
}
```

### Step 3: Terraform Creates Dependencies Graph

```
VPC Module
  ↓
  ├─→ ECR Module
  ↓
  └─→ ECS Module (needs VPC + ECR)
        ↓
        ├─→ CodeCommit Module
        ↓
        └─→ CodePipeline Module (needs ECR + CodeCommit)
              ↓
              └─→ Monitoring Module (needs ECS)
```

### Step 4: Terraform Creates Resources in Order

**VPC Module creates:**
```
1. VPC (10.0.0.0/16)
2. Internet Gateway
3. Public Subnets (10.0.0.0/24, 10.0.1.0/24)
4. Private Subnets (10.0.10.0/24, 10.0.11.0/24)
5. NAT Gateways (for private subnets)
6. Route Tables
7. VPC Flow Logs
```

**ECR Module creates:**
```
8. ECR Repository
9. Lifecycle Policy (keep 10 images)
10. Repository Policy
```

**ECS Module creates:**
```
11. ECS Cluster
12. Task Definition
13. Application Load Balancer
14. Target Group
15. Security Groups
16. ECS Service
```

And so on...

### Step 5: Outputs Displayed

```
Outputs:

primary_alb_url = "http://logicworks-devops-alb-us-east-1-593780670.us-east-1.elb.amazonaws.com"
secondary_alb_url = "http://logicworks-devops-alb-us-east-2-1135554901.us-east-2.elb.amazonaws.com"
primary_region = "us-east-1"
secondary_region = "us-east-2"
```



## Quick Reference Cheat Sheet

### Basic Syntax

```hcl
# Variable (input)
variable "name" {
  type    = string
  default = "value"
}

# Use variable
var.name

# Resource (create something)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Reference resource attribute
aws_vpc.main.id

# Module (reusable code)
module "vpc" {
  source = "./modules/vpc"
  name   = "my-vpc"
}

# Module output
module.vpc.vpc_id

# Output (display value)
output "vpc_id" {
  value = aws_vpc.main.id
}

# String with variable
"${var.name}-vpc"

# List/Array
["item1", "item2", "item3"]

# Map/Object
{
  key1 = "value1"
  key2 = "value2"
}

# Access list item
var.list[0]

# Access map value
var.map["key"]

# Loop (create multiple)
count = 3
count.index  # 0, 1, 2

# Explicit dependency
depends_on = [aws_internet_gateway.main]

# Conditional
count = var.create ? 1 : 0
```

### Common Functions

```hcl
# List operations
length(list)                    # Count items
concat(list1, list2)            # Merge lists
element(list, index)            # Get item at index

# String operations
format("Hello %s", var.name)    # String formatting
lower("ABC")                    # Lowercase
upper("abc")                    # Uppercase
join("-", list)                 # Join with separator

# Network functions
cidrsubnet("10.0.0.0/16", 8, 0) # Calculate subnet
cidrhost("10.0.0.0/24", 5)      # Calculate IP

# Encoding
jsonencode(value)               # Convert to JSON
base64encode(value)             # Base64 encode

# Conditionals
condition ? true_val : false_val
```

### Common Meta-Arguments

```hcl
# Create multiple resources
count = 3

# Create multiple with map
for_each = toset(["a", "b", "c"])

# Explicit dependency
depends_on = [aws_internet_gateway.main]

# Use specific provider
provider = aws.secondary

# Lifecycle options
lifecycle {
  create_before_destroy = true
  prevent_destroy       = true
  ignore_changes        = [tags]
}
```

### Terraform Commands

```bash
# Initialize
terraform init

# Validate syntax
terraform validate

# Format code
terraform fmt

# Plan changes (preview)
terraform plan

# Apply changes (create resources)
terraform apply

# Apply without confirmation
terraform apply -auto-approve

# Destroy all resources
terraform destroy

# Show current state
terraform show

# List resources in state
terraform state list

# Show specific resource
terraform state show aws_vpc.main

# Display outputs
terraform output

# Get specific output
terraform output vpc_id
```



## Practice Exercises

Try these to deepen your understanding:

### Exercise 1: Find Resources

Open `modules/ecs/main.tf` and identify:
1. How many resource blocks are there?
2. Which resources use `count`?
3. What does the ECS service depend on?

### Exercise 2: Trace Dependencies

In `main.tf`, follow how data flows:
1. Where does `vpc_id` come from?
2. How does ECS module get the VPC ID?
3. What outputs does the VPC module provide?

### Exercise 3: Understand Count

In `modules/vpc/main.tf`:
1. How many subnets are created?
2. What determines the number?
3. How are subnet CIDR blocks calculated?

### Exercise 4: Read Outputs

Open `outputs.tf`:
1. What information is displayed after deployment?
2. How are the ALB URLs constructed?
3. Which module provides the ALB DNS name?

### Exercise 5: Modify Configuration

Try changing these in `variables.tf`:
1. Change `primary_region` to `"us-west-1"`
2. Add a third availability zone to `primary_azs`
3. Change `project_name` to your own name

Then run `terraform plan` to see what would change.



## Common Patterns in Your Project

### Pattern 1: Multi-Region Deployment

```hcl
# Primary region
module "primary_vpc" {
  source = "./modules/vpc"
  providers = { aws = aws.primary }
  region = var.primary_region
}

# Secondary region (duplicate with different region)
module "secondary_vpc" {
  source = "./modules/vpc"
  providers = { aws = aws.secondary }
  region = var.secondary_region
}
```

### Pattern 2: Module Output Chaining

```hcl
# VPC outputs
module "primary_vpc" {
  # ... configuration
}

# ECS uses VPC outputs
module "primary_ecs" {
  vpc_id         = module.primary_vpc.vpc_id
  public_subnets = module.primary_vpc.public_subnets
}
```

### Pattern 3: Dynamic Resource Creation

```hcl
# Create one subnet per availability zone
resource "aws_subnet" "public" {
  count             = length(var.azs)
  availability_zone = var.azs[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
}
```

### Pattern 4: Default Tags

```hcl
provider "aws" {
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
```

All resources automatically get these tags!



## Troubleshooting Tips

### Error: "No such file or directory"

**Problem:** Terraform can't find a module
```
Error: Failed to read module directory
```

**Solution:**
```bash
terraform init  # Download modules
```

### Error: "Resource already exists"

**Problem:** Trying to create something that already exists

**Solution:**
```bash
# Import existing resource
terraform import aws_vpc.main vpc-123456

# Or destroy and recreate
terraform destroy
terraform apply
```

### Error: "Invalid provider configuration"

**Problem:** Missing or incorrect provider setup

**Solution:** Check that you have:
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

### Error: "Variables not set"

**Problem:** Required variable has no value

**Solution:** Provide value in:
1. `variables.tf` default
2. `terraform.tfvars` file
3. Command line: `terraform apply -var="name=value"`
4. Environment variable: `export TF_VAR_name=value`



## Additional Resources

### Official Documentation

- **Terraform Docs**: https://www.terraform.io/docs
- **AWS Provider**:
  https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **Terraform Registry**: https://registry.terraform.io/

### Learning Resources

- **HashiCorp Learn**: https://learn.hashicorp.com/terraform
- **Terraform Best Practices**: https://www.terraform-best-practices.com/
- **AWS Terraform Examples**: https://github.com/terraform-aws-modules

### Your Project Documentation

- `README.md` - Project overview
- `QUICKSTART.md` - Quick deployment guide
- `ARCHITECTURE.md` - Infrastructure architecture
- `TROUBLESHOOTING.md` - Common issues and solutions



## Summary

**Key Concepts You Learned:**

1. ✅ Terraform creates infrastructure from code
2. ✅ Variables make code flexible
3. ✅ Modules make code reusable
4. ✅ Resources create AWS infrastructure
5. ✅ Outputs display important information
6. ✅ State tracks what was created
7. ✅ Dependencies determine creation order
8. ✅ Count creates multiple resources
9. ✅ Functions help with calculations
10. ✅ Plan before Apply (preview changes)

**Your Project Deploys:**
- ✅ 75+ AWS resources
- ✅ 2 regions (us-east-1, us-east-2)
- ✅ Complete multi-tier application
- ✅ All with one command: `terraform apply`

**Next Steps:**
1. Run `terraform plan` and read the output
2. Modify a variable and see what changes
3. Explore each module to understand what it creates
4. Try the practice exercises above



**Happy Terraforming! 🚀**
