# 日本工学院八王子専門学校 Teraform実習

AWS上にインスタンスを作成するシンプルなTeraform用プロジェクトです。

## 準備
### AWS
#### IAMの作成
* Terraform用のユーザー(IAM)を作成します。
* 自身の端末に[awsコマンド](https://aws.amazon.com/jp/cli/)をインストールし設定用のコマンドを実行、ユーザー情報を保存します。

```sh
 $ aws configure
AWS Access Key ID : (作成したIAMの情報)
AWS Secret Access Key : (作成したIAMの情報)
Default region name: ap-northeast-1
Default output format: json
```

#### キーペアの作成
マネジメントコンソールから[EC2→キーペア](https://ap-northeast-1.console.aws.amazon.com/ec2/home?region=ap-northeast-1#KeyPairs:)とたどり、適当なキーペアを作成し保存します。

```sh
$ cp xxx.pem ~/.ssh/
$ chmod 0600 ~/.ssh/xxx.pem
```

公開鍵を作成します（[詳細](https://blog.katsubemakito.net/linux/generete-publickey-from-secretkey)）
```sh
$ ssh-keygen -y -f ~/.ssh/xxx.pem > ~/.ssh/xxx.pub
```

この情報はこれから作成するEC2に、SSHでログインする際に利用します。

### インストール
自身の端末にTerraformをインストールします。
https://developer.hashicorp.com/terraform/install

バージョン情報を表示するなどし、動作を確認します。
```sh
$ terraform --version
Terraform v1.7.0
on darwin_amd64
+ provider registry.terraform.io/hashicorp/aws v4.47.0
```

## 利用方法
### 初期化
現在のディレクトリを初期化します。`successfully initialized!`と表示されれば成功です。これは最初の1回だけ行います。
```sh
$ terraform init
(中略)
Terraform has been successfully initialized!
```

### 確認
現在の設定情報が実行できるか、念のため確認します。`plan`コマンドはAWS上に一切影響を及ぼしません。
```sh
$ terraform plan
```

### 実行
`plan`でエラーなどが発生しなければ`apply`でAWS上に反映します。このコマンドは実際にAWSにインスタンスを作成します（料金が発生します）
```sh
$ terraform apply
 Enter a value: (yesと入力)
(中略)
Apply complete! Resources: 12 added, 0 changed, 0 destroyed.
```
最後に`Apply complete!`のメッセージが表示されていれば成功です。

実際にマネジメントコンソールからインスタンスが作成されているか確認します。

### インスタンスの動作確認
実際にSSHでログインして確認します。
```sh
$ ssh ec2-user@(IPアドレス) -i ~/.ssh/xxx.pem
```

またApacheがインストールされていますので、Webブラウザなどからアクセス可能か確認します。
```sh
$ curl --head http://54.238.184.208/
```

### インスタンスの削除
`destroy`コマンドで作成したものをすべて削除します。実際にインスタンスが消えてなくなるため実行する際は注意してください。
```sh
$ terraform destroy
  Enter a value: (yesを入力)
(中略)
Destroy complete! Resources: 12 destroyed.
```

最後に`Destroy complete!`と表示されれば成功です。
