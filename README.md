Evernoteを活用したニュース分類器
===========================

Evernoteの情報を元に最新のニュース記事を4つのカテゴリに分類するWebアプリである．
各記事はスコア付けされ，各カテゴリごとにスコアの高い上位5記事が表示される．
実際に動いている様子はこちらを参照のこと（2014/03/07現在）
http://koike55net.sakura.ne.jp/classifier/index.cgi

必要なライブラリ等
---------------

* 1.9.2以降のRuby (2.0.0で動作確認)
* MeCab，MeCab-Ruby
* RubyGem
** Sinatra
** Nokogiri
** evernote-thrift
** evernote-oauth

準備
------

* Evernote APIキーを取得する (本番環境とサンドボックス環境があり，本番環境が使えるようになるには時間がかかるので注意)
  http://dev.evernote.com/documentation/cloud/
* 上記のライブラリ等をインストールする
* evernote_config.rb の各関数を自分の環境に合わせて書き換える
** auth_key: Evernote APIを使うためのキーを返す
** auth_secret: Evernote APIを使用するためのパスワードを返す
** auth_token: Evernote APIに必要なトークンを返す（詳細はEvernote APIの資料を参照のこと）
** reject_notebook: 指定されたノートブックを分類に使用しない時，trueを返す．もしノートブックによるフィルタリングをしないのであれば，常にfalseを返す．
** reject_note: 指定されたノートを分類に使用しない時，trueを返す．もしノートによるフィルタリングをしないのであれば，常にfalseを返す．
** get_category: 指定されたノートのカテゴリを返す．本アプリはこの関数で指定されたカテゴリに基づいて，ニュースの分類を行う．

各種データの生成
-------------

### Evernoteからノートを収集する．（ノート情報はnotes.jsonに保存される）
```
$ ruby generate_notes_json.rb
```

### Evernoteから取得したノート情報を利用して，ナイーブベイズ分類器のモデル推定を行う．（パラメータはclassifier.jsonに保存される）
```
$ ruby train.rb
```

### Web上のニュースサイトからニュース記事を収集する．（収集した記事はarticles.jsonに保存される）
```
$ ruby generate_articles_json.rb
```

### ニュース記事の分類を行う．（記事の分類結果はcontents.jsonに保存される）
```
$ ruby generate_contents_json.rb
```

Webアプリの起動
----------

```
$ ruby main.rb
```

開発環境では アプリのURLは http://localhost:4567/ となる．終了するにはターミナルで ctrl-c．
