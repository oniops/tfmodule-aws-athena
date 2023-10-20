# tfmodule-aws-athena

AWS Athena 워크 그룹을 구성 하는 테라폼 모듈 입니다.

## Usage

```
module "athena" {
  source = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-athena.git"

  context = {
    project     = "demo"
    region      = "ap-northeast-2"
    name_prefix = "demo-an2d"
    domain      = "your.public.domain"
    tags = {
      Team = "DevOps"
    }    
  }

  work_group         = "demo"
  s3_output_location = "s3://your-s3-bucket/athena/output"

}

```