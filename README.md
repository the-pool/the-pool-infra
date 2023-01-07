# The Pool infra
The Pool 인프라 구성도 및 사용방법입니다.  

<br />  

### Infra 구성도
![ThePool](https://user-images.githubusercontent.com/52196792/210201453-eb0489ab-45ce-4cb3-8809-1a66690fd22d.png)  
![ThePool by pluralith](https://user-images.githubusercontent.com/52196792/211160204-40b771d5-7cfd-4395-bf7e-69518f6fa30a.png)


<br />  

**IAM 구조**  
![ThePool iam](https://user-images.githubusercontent.com/52196792/211160142-c0d91437-0ab9-4cb7-bf0b-91fb3152093c.png)



<br />  

### 디렉터리 구조
```bash
.
├── README.md
├── modules
│   ├── acm
│   ├── api_gateway
│   ├── cloudfront
│   ├── ec2
│   ├── ecr
│   ├── iam_role
│   ├── lambda
│   ├── route53
│   ├── s3
│   ├── security_group
│   └── vpc
├── outputs.tf
├── provider.tf
├── root.tf
├── terraform.tfstate
├── terraform.tfstate.backup
├── terraform.tfvars
└── variables.tf
```

<br />

### AWS CLI & Terraform 다운로드  
👉 [AWS CLI 다운로드](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/getting-started-install.html)  
👉 macOS Homebrew를 이용한 Terraform 다운로드
```sh
$ brew install terraform@1.2
$ terraform --version
Terraform v1.2.9
```  

<br />  

### profile 설정
👉 AWS IAM 생성(말씀해주시면 생성해드립니다)
👉 로컬에 자격증명 저장
```sh
$ aws configure set --profile thepool
AWS Access Key ID [None]: ${지급받은 Access Key}
AWS Secret Access Key [None]: ${지급받은 Secret Access Key}
Default region name [None]: 
Default output format [None]: json
```


<br />  

### key pair 생성 or 지급
👉 EC2 접근을 위한 key pair 생성(말씀해주시면 기존 ssh 지급해드립니다)  
```sh
# -t: 암호화 타입
# -b: 비트 수
# -C: 코멘트
# -f: 파일 저장 경로
# -N: 암호화 옵션
ssh-keygen -t rsa -b 4096 -C "key pair" -f "$HOME/.ssh/{key pair name}" -N ""
```  
👉 EC2 Securitu Group 인바운드룰에 IP 추가  
👉 EC2 ssh 접근  
```sh  
ssh -i ~/.ssh/{key pair name} ec2-user@{EC2 IP}
```  


<br />  

### 테라폼 명령
```sh
$ terraform init
$ terraform plan
# 인프라 적용시
$ terraform apply
```  

<br />  

### 테라폼 시각화 툴 - pluralith
- [pluralith 다운](https://docs.pluralith.com/docs/category/get-started)  
- [소개 및 참고 블로그](https://www.saltedcoke.com/?p=95)
