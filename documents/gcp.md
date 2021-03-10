## gcpの構築手順
## インスタンスの構築手順
- step 1 インスタンス作成  
  - メニュー開く  
  - Compute Engineクリック
  - vmインスタンスクリック  
    
  ![System Configuration](images/1.png)
   

 - step 2 インスタンス作成画面を起動
   ![System Configuration](images/2.png)  
   

- step 3 スペック選択
   - インスタンスの名前記述
   - リージョンを選択 asia-northeast1 asia-northeast1-a
   - スペックを選択  汎用-E2-e2-medium (2 vCPU,4GB　メモリ)  
    
  ![System Configuration](images/4.png)
     
- step 4 os選択,http通信許可 
   - OSをUbuntu 18.04 LTSに選択
   - ファイアウォールのhttp,httpsを許可させる

  ![System Configuration](images/5.png)

- step 5 ネットワーク画面設定画面を開く
  - ネットワークのタグを作成
  - グローバルIPの予約画面を開く

  ![System Configuration](images/6.png)  


 - step 6 静的グローバルアドレスを予約
   - 名前記述（自由
   - 標準を選択 (プレミアムでも可
    
   ![System Configuration](images/7.png)

- step 7 設定を確定
  - グローバルIPを確認
  - ネットワークの設定を完了し確定
  - インスタンスを作成
  
  ![System Configuration](images/8delete.png)


##　ファイアウォールの設定
- step 1 ファイアウォール画面を開く
  - VPCネットワークをクリック
  - ファイアウォール設定画面を開く
  
  ![System Configuration](images/f1.png)


- step 2 全default ルールの確認し、変更させる
  - 全てのインスタンスに適用するようにに変更
  - フィルタをedgeが存在するネットワークのグローバルIPに限定する
  
  ![System Configuration](images/f3delete.png)


- step 3 step2の実行方法
  - defaultルールをクリックし、編集画面を開く
  - ターゲットを「ネットワーク上の全てのインスタンス」に変更
  - ソースIPの範囲をedgeのグローバルIPに限定　例: 8.8.8.8/32
  - 保存します
  ![System Configuration](images/f4.png)


- step 4 新規ファイルウォールルール
  - ファイルウォール画面にて「新規ファイルウォールルールを作成」ボタンクリック
  - ターゲットを「ネットワーク上の全てのインスタンス」に変更
  - ソースIPの範囲をedgeのグローバルIPに限定　例: 8.8.8.8/32

  ![System Configuration](images/f5.png)

- step 5 開通ポート番号を指定
  - プロトコルとポートを指定:
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
  - 保存します。
  
  ![System Configuration](images/f6.png)  

## GCEの構築は以上で終了
