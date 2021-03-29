# AION Cluster用 GCP構築手順

**目次**

* [GCE インスタンスの構築](#GCE-インスタンスの構築)
    * [Step1: VMインスタンス一覧画面へ移動](#Step1:-VMインスタンス一覧画面へ移動)
    * [Step2: インスタンス作成画面へ移動](#Step2:-インスタンス作成画面へ移動)
    * [Step3: スペック選択](#Step3:-スペック選択)
    * [Step4: os選択,http通信許可 ](#Step4:-os選択,http通信許可 )
    * [Step5: ネットワーク設定](#Step5:-ネットワーク設定)
    * [Step6: 静的グローバルアドレスを予約](#Step6:-静的グローバルアドレスを予約)
    * [Step7: 設定を確定](#Step7-設定を確定)
* [ファイアウォールの設定](#ファイアウォールの設定)
    * [Step1: ファイアウォール設定画面へ移動](#Step1:-ファイアウォール設定画面へ移動)
    * [Step2: 全default ルールの確認、変更](#Step2:-全default-ルールの確認、変更)
    * [Step3: 新規ファイルウォールルール作成](#Step3:-新規ファイルウォールルール作成)
    * [Step4: 開通ポート番号を指定](#Step4:-開通ポート番号を指定)


## GCE インスタンスの構築

### Step1: VMインスタンス一覧画面へ移動
  1. メニュー一覧を開く
  2. Compute Engineをクリック
  3. VMインスタンスをクリック


  ![System Configuration](images/1.png)


### Step2: インスタンス作成画面へ移動
  1. インスタンス作成ボタンクリック


   ![System Configuration](images/2.png)


### Step3: スペック選択
   1. インスタンスの名前記述
   2. リージョンを選択 asia-northeast1 asia-northeast1-a
   3. スペックを選択  汎用-E2-e2-medium (2 vCPU,4GB　メモリ)


  ![System Configuration](images/4.png)


### Step4: os選択,http通信許可
   1. OSをUbuntu 18.04 LTSに選択
   2. ファイアウォールのhttp,httpsを許可させる


  ![System Configuration](images/5.png)


### Step5: ネットワーク設定
  1. ネットワークのタグを作成
  2. グローバルIPの予約画面を開く


  ![System Configuration](images/6.png)



### Step6: 静的グローバルアドレスの予約
  1. 名前記述（自由
  2. 標準を選択 (プレミアムでも可


   ![System Configuration](images/7.png)


### Step7: 設定を確定
  1. グローバルIPを確認
  2. ネットワークの設定を完了し確定
  3. インスタンスを作成


  ![System Configuration](images/8.png)


## ファイアウォールの設定

### Step1: ファイアウォール設定画面への移動
  1. VPCネットワークをクリック
  2. ファイアウォール設定画面を開く


  ![System Configuration](images/f1.png)


### Step2: 全default ルールの確認、変更
  1. 全てのインスタンスに適用するようにに変更
  2. フィルタをedgeが存在するネットワークのグローバルIPに限定する


  ![System Configuration](images/f3.png)


#### defaultルールの変更方法
  1. defaultルールをクリックし、編集画面を開く
  2. ターゲットを「ネットワーク上の全てのインスタンス」に変更
  3. ソースIPの範囲をedgeのグローバルIPに限定　例: 8.8.8.8/32
  4. 保存します


  ![System Configuration](images/f4.png)


### Step3: 新規ファイルウォールルール作成
  1. ファイルウォール画面にて「新規ファイルウォールルールを作成」ボタンクリック
  2. ターゲットを「ネットワーク上の全てのインスタンス」に変更
  3. ソースIPの範囲をedgeのグローバルIPに限定　例: 8.8.8.8/32


  ![System Configuration](images/f5.png)


### Step4: 開通ポート番号を指定
  1. プロトコルとポートを指定:
     ```text
     tcp:6443
     tcp:2379-2380
     tcp:10250
     tcp:10251
     tcp:10252
     tcp:10250
     tc:53,9153
     udp:53
     ```
  2. 保存します。


  ![System Configuration](images/f6.png)  


## GCEの構築は以上で終了
