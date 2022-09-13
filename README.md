# tfmodule-aws-athena

AWS Athena 워크 그룹을 구성 하는 테라폼 모듈 입니다.

## Usage

```
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

```
