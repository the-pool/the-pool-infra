# The Pool infra
The Pool 인프라 구성도 및 사용방법입니다.  

<br />  

### Infra 구성도
![thePool](https://user-images.githubusercontent.com/52196792/210201453-eb0489ab-45ce-4cb3-8809-1a66690fd22d.png)

<br />  

### 디렉터리 구조

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
