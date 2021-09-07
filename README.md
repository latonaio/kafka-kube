# kafka-kube

kafka-kube は k8s 上に構築された kafka と zookeeper によって構築された分散メッセージキューサービスです。
kafka-kube では、複数のサービス間でのデータの受け渡しを仲介するミドルウェアである kafka と、分散システムの設定共有やグルーピングをサポートするコーディネーションエンジンである zookeeper の組み合わせによって、高負荷環境においても安定して分散システムを運用することを可能にします。

# 概要

kafka-kube は複数のマイクロサービスに対してメッセージキューサービスを提供し、サービス間の pub/sub を実現します。
publisher によって送信された record は broker に送信され、対応するpartitionに格納されます。zookeeper はこの broker 間の連携に利用され、leader broker の選出を行います。  
このように、partition 単位で record の書き込み/読み込みを行うことによって、subscriber は並列な書き込み/読み込みを行うことが可能になります。  
kafka-kubeは、冗長性を確保するため、kafka 3台、zookeeper 3台によって構成されています。

# 構築手順一覧
-  gcpとedgeのハイブリッド環境構築手順
    - [gcp構築手順](documents/gcp.md)
    - [openvpn構築手順](documents/openvpn.md)
    - [k8s構築手順](documents/buildk8s.md)

# 動作環境

kafka-kube は kubernetes 上での動作を前提としています。


- OS: Linux

- CPU: Intel64/AMD64 (armは現在未対応)

- Kubernetes

最低限スペック
CPU: 2 core
memory: 4 GB


# 起動方法

このリポジトリをクローンし、makeコマンドを用いてサービスを起動してください。

```shell
$ cd /path/to/kafka-kube

#起動
$ make start-all

#停止
$ make delete-all
```

# Input

publisher から送信されたメッセージ。データベースからの通知や、アプリケーションログ等をメッセージとして使用することができます。

# Output

broker に送られたメッセージ。consumer は topic と partition を指定することでメッセージを利用することができます。


# アクセス方法

```shell
# k8sのcluster内ではkafkaのproducer,consumerのclient sdkを使って下記のエンドポイントに対して通信
kafka-${BROKER_NUMBER}.kafka-service.default.svc.cluster.local:9092
```
# システム構造

![System Configuration](documents/images/0.png)

# 使用したdocker image

```markdown
### kafka image
- https://hub.docker.com/r/wurstmeister/kafka/
### zookeeper image
- https://hub.docker.com/_/zookeeper
```

