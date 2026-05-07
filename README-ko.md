# tfmodule-aws-athena

AWS Athena 워크그룹을 구성하는 테라폼 모듈입니다.

> 한국어 문서입니다. 영문 문서는 [README.md](./README.md)를 참고하세요.

## Features

- Athena 워크그룹 생성 (운영 스택별로 생성 여부를 동적으로 토글 가능)
- 쿼리 결과 저장 S3 위치 및 예상 버킷 소유자(Expected Bucket Owner) 설정
- 서버 사이드/클라이언트 사이드 암호화 옵션 지원 (`SSE_S3`, `SSE_KMS`, `CSE_KMS`)
- S3 ACL 옵션 (`BUCKET_OWNER_FULL_CONTROL`) 지원
- 쿼리당 스캔 데이터 한도(Cutoff) 설정
- CloudWatch 메트릭 게시 및 워크그룹 설정 강제(Enforce) 옵션
- 워크그룹 이름은 `${context.name_prefix}-${var.work_group}-athwg` 규칙으로 자동 부여

## Usage

### 기본 사용 예제

```hcl
module "ctx" {
  source = "git::https://github.com/oniops/tfmodule-context.git?ref=v1.3.5"
  context = {
    region      = "ap-northeast-2"
    project     = "demo"
    environment = "Development"
    owner       = "master@demoworks.com"
    team        = "DevOps"
    cost_center = "20211129"
    domain      = "demo.demoworks.com"
    pri_domain  = "demo.internal"
  }
}

module "athena" {
  source             = "git::https://github.com/oniops/tfmodule-aws-athena.git?ref=v1.0.0"
  context            = module.ctx.context
  work_group         = "demo"
  s3_output_location = "s3://your-s3-bucket/athena/output"
}
```

### 워크그룹 생성 비활성화

운영 스택별로 워크그룹 생성 여부를 동적으로 제어할 때 사용합니다.

```hcl
module "athena" {
  source  = "git::https://github.com/oniops/tfmodule-aws-athena.git?ref=v1.0.0"
  create  = false
  context = module.ctx.context

  work_group         = "demo"
  # create = false 라도 변수 자체는 필수이므로 유효한 s3:// 경로를 넘겨야 합니다.
  s3_output_location = "s3://your-s3-bucket/athena/output"
}
```

### KMS 암호화 + S3 ACL 적용 예제

```hcl
module "athena" {
  source                   = "git::https://github.com/oniops/tfmodule-aws-athena.git?ref=v1.0.0"
  context                  = module.ctx.context
  work_group               = "demo"
  s3_output_location       = "s3://your-s3-bucket/athena/output"
  s3_expected_bucket_owner = "123456789012"
  encryption_option        = "SSE_KMS"
  kms_key_arn              = "arn:aws:kms:ap-northeast-2:123456789012:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  enabled_s3_acl_option    = true

  enforce_workgroup_configuration    = true
  publish_cloudwatch_metrics_enabled = true
  bytes_scanned_cutoff_per_query     = 10485760
}
```

## Inputs

### context

| Name          | Description                              | Type          | Required |
|---------------|------------------------------------------|---------------|:--------:|
| `region`      | AWS 리전                                  | `string`      | yes      |
| `project`     | 프로젝트명                                  | `string`      | yes      |
| `name_prefix` | 리소스 이름 접두사                            | `string`      | yes      |
| `pri_domain`  | 내부(Private) 도메인                        | `string`      | yes      |
| `tags`        | 공통 태그                                  | `map(string)` | yes      |

### Module Variables

| Name                                 | Description                                                                                          | Type     | Default | Required |
|--------------------------------------|------------------------------------------------------------------------------------------------------|----------|---------|:--------:|
| `create`                             | 워크그룹 생성 여부. `false`면 모듈이 어떤 리소스도 생성하지 않음                                       | `bool`   | `true`  | no       |
| `work_group`                         | 워크그룹 이름 (실제 생성 이름은 `${name_prefix}-${work_group}-athwg`)                                 | `string` | n/a     | yes      |
| `s3_output_location`                 | 쿼리 결과 저장 S3 위치 (`s3://` 프리픽스 필수)                                                       | `string` | n/a     | yes      |
| `s3_expected_bucket_owner`           | 결과 저장 S3 버킷의 예상 소유자 AWS 계정 ID                                                          | `string` | `null`  | no       |
| `enforce_workgroup_configuration`    | 워크그룹 설정을 클라이언트 측 설정보다 우선 적용할지 여부                                              | `bool`   | `false` | no       |
| `publish_cloudwatch_metrics_enabled` | CloudWatch 메트릭 게시 여부                                                                          | `bool`   | `true`  | no       |
| `s3_bucket_requester_pays_enabled`   | Requester Pays S3 버킷 참조 허용 여부                                                                | `bool`   | `false` | no       |
| `bytes_scanned_cutoff_per_query`     | 단일 쿼리당 스캔 가능 바이트 한도 (최소 `10485760`)                                                  | `number` | `null`  | no       |
| `encryption_option`                  | 암호화 옵션 (`SSE_S3` / `SSE_KMS` / `CSE_KMS`). `null`이면 비활성화                                  | `string` | `null`  | no       |
| `kms_key_arn`                        | `SSE_KMS` 또는 `CSE_KMS` 사용 시 KMS 키 ARN                                                          | `string` | `null`  | no       |
| `enabled_s3_acl_option`              | S3 ACL 옵션 활성화 여부. `true`인 경우 `BUCKET_OWNER_FULL_CONTROL`이 적용됨                          | `bool`   | `false` | no       |

### 암호화 활성화 조건

`encryption_configuration` 블록은 다음 조건에서 활성화됩니다.

- `encryption_option = "SSE_S3"` 인 경우, 또는
- `encryption_option`이 `null`이 아니고 `kms_key_arn`이 함께 지정된 경우 (`SSE_KMS`, `CSE_KMS`)

## Outputs

| Name             | Description           |
|------------------|-----------------------|
| `workgroup_id`   | 생성된 워크그룹 ID     |
| `workgroup_name` | 생성된 워크그룹 이름   |
| `workgroup_arn`  | 생성된 워크그룹 ARN    |

> `create = false`로 워크그룹을 생성하지 않은 경우, 위 출력값은 모두 빈 문자열(`""`)을 반환합니다.
