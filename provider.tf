/*#################################
  Terraform 설정(버전, provider 버전)
#################################*/
terraform {
  required_version = "1.2.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.33.0"
    }
  }
}

/*#################################
  Provider설정(사용리전, 글로벌리전 등록)
#################################*/
provider "aws" {
  region                   = "ap-northeast-2"
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "thepool"
}

provider "aws" {
  alias                    = "virginia"
  region                   = "us-east-1"
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "thepool"
}
