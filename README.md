# kafka-kube

kafka-kube は、k8s上に構築された Kafka と Zookeeper による 分散メッセージキューサービス です。
kafka-kube では、複数のサービス間でのデータの受け渡しを仲介するミドルウェアである Kafkaと、分散システムの設定共有やグルーピングをサポートするコーディネーションエンジンである Zookeeper の組み合わせによって、高負荷環境においても安定して分散システムを運用することを可能にします。  
AION において kafka-kube は、主にエッジコンピューティング環境での利用を想定しています。


# 概要

kafka-kube は、複数のマイクロサービスに対してメッセージキューサービスを提供し、サービス間のpub/subを実現します。  
publisherによって送信されたrecordはbrokerに送信され、対応するpartitionに格納されます。zookeeperはこのbroker間の連携に利用され、leader brokerの選出を行います。  
このように、partition単位でrecordの書き込み/読み込みが行われることによって、subscriberは並列な書き込み/読み込みを行うことが可能になります。  
kafka-kubeは、冗長性を確保するため、kafka 3台、zookeeper 3台 によって構成されています。

# 構築手順（GCPとエッジのハイブリッド環境）
-  gcpとedgeのハイブリッド環境構築手順
    - [gcp構築手順](documents/gcp.md)
    - [openvpn構築手順](documents/openvpn.md)
    - [k8s構築手順](documents/buildk8s.md)

# 動作環境

kafka-kube は、Kubernetes上での動作を前提としています。

```  
OS: Linux
CPU: Intel/AMD (ARMは未対応)
Kubernetes  

最低限スペック
CPU: 2 core
memory: 4 GB

```  

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

publisherから送信されたメッセージ。データベースからの通知や、アプリケーションログ等をメッセージとして使用することができます。

# Output

brokerに送られたメッセージ。consumerはtopicとpartitionを指定することでメッセージを利用することができます。


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