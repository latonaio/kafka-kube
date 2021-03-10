# openvpnのserver,clientの構築手順
## Server, Client共通作業
```shell
#OpenVPNのインストール
sudo apt install openvpn easy-rsa
Server側での作業
#環境設定ファイルの作成
make-cadir ~/ca
sudo vi ~/ca/vars
```
```text
#変更前
export KEY_COUNTRY="US"
export KEY_PROVINCE="California"
export KEY_CITY="San Francisco"
export KEY_ORG="Copyleft Certificate Co"
export KEY_EMAIL="me@example.net"
export KEY_OU="My Origanizational Unit"
#変更後(自由に記述)
export KEY_COUNTRY="JP"
export KEY_PROVINCE="TKYO"
export KEY_CITY="Shibuya"
export KEY_ORG="Aion" #Client名
export KEY_EMAIL="xxxxx@gmail.com"
export KEY_OU="vpn"
```
```shell
#　config作成
cp openssl-1.0.0.cnf openssl.conf
cd ~/ca
#環境変数適用
source vars
#CA証明書と秘密鍵の作成
./build-ca
#サーバー証明書と秘密鍵の作成
./build-key-server server
#DHパラメータ生成
./build-dh
#TLS認証用秘密鍵の作成
openvpn --genkey --secret keys/ta.key
#必要なファイルを配置
sudo cp -r ./keys /etc/openvpn
```
```shell
#以下のファイルが/etc/openvpn/keys/に配置されていることを確認
<!--
ca.crt CA証明書
ca.key  CA秘密鍵
server.crt  サーバー証明書
server.key  サーバー秘密鍵
dh2048.pem  DHパラメータ
ta.key  TLS認証用秘密鍵 
-->
```

```shell
#Client証明書の作成
./build-key aion

#OpenVPN作業
cd /etc/openvpn/
sudo touch server.conf
sudo chmod 755 server.conf
#server.confに以下を書き込み
sudo vi server.conf
```
```text
port   11940 #ポート番号
proto  udp #プロトコル
dev    tun #ルーティング方式を使用

ca          /etc/openvpn/keys/ca.crt #CA証明書の名称
cert        /etc/openvpn/keys/server.crt #サーバー証明書の名称
key         /etc/openvpn/keys/server.key #サーバー秘密鍵の名称
dh          /etc/openvpn/keys/dh2048.pem #DHパラメータの名称

ifconfig-pool-persist ipp.txt #IPアドレスのテーブルファイル
server 10.0.0.0 255.255.240.0 #VPNで使用するプライベートIPとサブネットマスク

;push "redirect-gateway def1 bypass-dhcp" #トラフィックの全てをOpenVPN経由とする
ifconfig-pool-persist ipp.txt
push "route 10.0.0.0 25.0.0.0"
push "dhcp-option DNS 8.8.8.8" #GoogleDNSを使用

tls-auth /etc/openvpn/keys/ta.key 0 #TLS認証有効化
;cipher AES-256-CBC #認証形式
;auth SHA512 #認証形式
comp-lzo #転送データのlzo圧縮有効化
client-to-client #クライアント間の接続を許可
keepalive 10 120 #生存確認を実施

user  nobody
group nogroup #Ubuntuはnobodyではなくnogroup

persist-key #設定の永続化
persist-tun

client-config-dir /etc/openvpn/ccd #クライアント別の設定ディレクトリからの設定の読み込みを有効にする

status      /var/log/openvpn-status.log
log         /var/log/openvpn.log
log-append  /var/log/openvpn.log

verb 3 #ログレベル
```

```shell
#Server側のOpenVPNを起動
sudo systemctl start openvpn@server
```


# Client側の作業
```shell
cd /etc/openvpn/
sudo touch client.conf
sudo chmod 755 client.conf
#client.confに以下を書き込み
sudo vi client.conf
```
```text
# クライアントモードであることを宣言
client
# VPNプロトコル：ルーティング方式
dev tun
# 通信プロトコル: UDP．
proto udp
remote-cert-tls server
# グローバルIPアドレスを指定する．「1. 準備」で調べたIP.
remote xx.xx.28.240 11940
;route-up "route add -net 10.0.0.0/20 gw xx.xx.28.240"
# 接続の継続．
resolv-retry infinite
# ポート番号をバインドしない．ほとんどの場合はこうらしい．
nobind
# 切断後の動作指定
persist-key
persist-tun
# 認証局証明書/クライアント証明書認証鍵．/etc/openvpn からのパス．
ca /etc/openvpn/keys/ca.crt
cert /etc/openvpn/keys/aion.crt
key /etc/openvpn/keys/aion.key
# LZO圧縮を有効に
key-direction 1
tls-auth /etc/openvpn/keys/ta.key 1
comp-lzo
# ログレベル
verb 3
```

```shell
#Server側で生成した以下の証明書、認証鍵をClient側の/etc/openvpn/keys/に配置する
<!--
ca.crt CA証明書
aion.crt  クライアント証明書
aion.key  クライアント秘密鍵
ta.key  TLS認証用秘密鍵 
-->

#Client側のOpenVPNを起動
sudo systemctl start openvpn
````

# Client側の仮想IPの固定化
```shell
#Server側でOpenVPNによる仮想IPが生成されていることを確認
sudo cat /var/log/openvpn-status.log
#またはClient側で仮想IPが生成されていることを確認することもできる
ip -a
#ここでClient側の仮想IPとpeerを確認すること

#Server側でClientの仮想IPを固定する
cd /etc/openvpn/
mkdir ccd
vim ./ccd/Client名 #ここではaion
```
```shell
#実行コマンド　Client仮想IPアドレス　サーバ固定IPアドレスの順に記載
#ip -aで調べたIPとpeerがこれに対応
ifconfig-push 10.0.0.6 10.0.0.5
```
```shell
#Server側のOpenVPNを再起動
sudo systemctl restart openvpn@server
#Client側のOpenVPNを再起動
sudo systemctl restart openvpn
```


