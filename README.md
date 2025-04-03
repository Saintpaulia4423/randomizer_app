# Randomizer app  

ウェブアプリケーションの勉強のために開発したものです。  
未整理のため、以下のように展開し直す必要があります。

```
.
├── compose.yaml（同梱のファイルを出す）  
├── .env（composeのenvironmentでも利用）  
├── secret（同梱のフォルダを出す）  
│   ├── .env  
│   └── pemとかkeyとか  
├── nginx（同梱のフォルダを出す）  
│   └── reverse.conf（server_nameなどは変更する必要あり）  
└── rails_application（名称は自由に）  
    └── .env（環境変数ファイルは最初から入れる）  
```
---

`cloudflare tunnel`を利用しているため、`docker compose up`するためには、以下のリンクを参考にcloudflareの利用を進める必要があります。  
無料の範囲で利用できますが、ドメインの取得が必要です。（uploadしているものはDDNS nowにて取得）

 - [主な概略](https://zenn.dev/matsubokkuri/articles/cloudflare-service)
 - [公式ドキュメント（cloudflare)](https://developers.cloudflare.com/ssl/origin-configuration/origin-ca/)

なおnginxはhttps通信も用意しましたが、cloudflare CDNと直接通信となるため、オリジン証明書の設定のみでhttps通信が確立したため、443portは記述はあるものの使用不可の状態です。
