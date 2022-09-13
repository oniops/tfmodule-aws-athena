module "athena" {
  source = "../../"

  context = {
    project     = "demo"
    region      = "ap-northeast-2"
    environment = "Development"
    department  = "DevOps"
    owner       = "devops@your.company"
    customer    = "Your Customer"
    domain      = "your.public.domain"
    pri_domain  = "your.private.domain"
    name_prefix = "demo-an2d"
    tags = {
      Team = "DevOps"
    }
  }

  work_group         = "demo"
  s3_output_location = "s3://your-s3-bucket/athena/output"
}

