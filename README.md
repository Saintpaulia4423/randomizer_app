# Randomizer app
---

ルートボックス（一般名称はガチャ）を自由に作成、共有を行えるサイトです。
ランダマイザー処理についてはJavascriptを利用しており、ローカル内で完結します。

<img width="500" alt="サイトのトップ画像" src="/readme/image_head.jpg">
<img width="500" alt="利用時の画像" src="/readme/usecase.png">

## サイトURL
---
https://app.randomizer-application.f5.si
セットの作成ではユーザー作成を必要としません。
ゲストのままお試しできます。

<br>
<br>

## 利用方法

---

- セットの作成
  セットを作成します。ユーザーせずに利用できますが、作成時の`パスワード`は変更できません。
  <img width="500" alt="利用中の画像" src="/readme/random_set_new_page.png">
- ランダマイザーの編集
  作成後は自動的に編集画面に遷移し、レアリティなどの情報を追加できます。
  セッション情報を保持するので、簡単に遷移してチェックもできます。
  注意点として２つのレアリティ情報（`抽選率`、`ピックアップ抽選率`）は必須となります。
  確率は合算して100に調整する必要はなく、100の倍数になるように調整され、レアリティ設定がされていないロットを作成しても`(100の倍数-抽選率の合計)%`で自動計算されます。
  <img width="300" alt="編集画面" src="/readme/edit_page.png"><img width="300" alt="レアリティを追加" src="/readme/add_reality.png"><img width="300" alt="ロットの追加" src="/readme/add_lot.png">
- 使ってみる
  ユーザー登録して作成すると自動的に制作者名が表記されます。
  また、セット設定が適切にされていない場合はレアリティ情報などが表示されません。この場合、は右上の編集から再度編集し直す必要があります。
  <img width="400" alt="ランダマイザー画面" src="/readme/user_created_random_set.png"><img width="400" alt="使用中" src="/readme/usercase2.png">

- ユーザー機能
  利便性のため、ユーザー登録せずとも各種機能を利用できますが、ユーザー登録すると少しだけ便利になります。
  <img width="400" alt="お気に入り" src="/readme/add_favorite.png"><img width="300" alt="" src="/readme/created_user.png">
  - 追加機能
    - お気に入り
    - 制作者表示
    - 上記２つのお気に入り数の表示とリンク


## 使用技術

---
- Ruby 3.2.2
- Ruby on Rails 7.2
  - RSpec
  - Stimulus
  - turbo-drive/turbo-frame/turbo-stream
- postgreSQL 16.4
- Proxmox
  - nfs-server
  - Docker/Docker-compose/Docker-swarm/Docker-stack
    - Nginx:1.27.4
    - Cloudflared
    - Portainer.io:2.27.0
    - Docker Registry:3.0

<br>
<br>

## 機能一覧

---
- ルートボックス・セット
  - レアリティ別の抽選率の設定
  - ピックアップ設定、ピックアップの確率設定
  - 個数を持つルートボックス（ボックスガチャ機能）
  - 上記3点について、編集権限のない利用者においても利用中での一時的変更が可能（HTMLベースの変更）
  - ランダマイザーについてはJavascriptを利用し、ローカル内で完結
  - Ransackを使った検索機能
- ユーザー機能
  - お気に入り機能
  - 作成したもの記録
- Turbo-frame/Turbo-streamを利用した、Rails7標準のサイト構成
- CDNを利用したサーバ公開（Cloudflare CDN）
- ルーターのポート開放、固定IPアドレスを必要としないCloudflare CDNとのtunneling（Cloudflared）
- Docker-stackを使った閉鎖ネットワークによるアプリケーション公開

<br>
<br>

## 構成図

---

![構成図](/readme/structure.jpg)
docker-swarm/stackを利用し可用性の向上を図っています。
また、docker back_networkについては`internal: true`をかけて通信制御を行い、外部への通信を遮断します。

## ER図

---

![ER図](/readme/ER.drawio.png)

<br>
<br>

### 今後の展望

---
- 任意のセットをベースにModが作成できるようにする。
- セットを纏めたパック（任意の複数のセットの集まり）を作成し、パックでのランダマイザーを行えるようにする。
- タグ機能を追加し、よりセットの検索性を向上させる。
- リザルトの視認性を向上するためグラフ機能や出現散布図
- Docker-Swarm以外でのDeploy（想定よりもdocker-stackの仕様が悪く、将来的にK8sを予定）
  - K8sと前後してCI/CUを設定
