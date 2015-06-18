# LivedoorRSSReader_iOSとは
livedoor NEWS（http://news.livedoor.com/) のRSS機能を用いて、ニュース記事を表示するiphone向けのアプリです。

### カテゴリ
- 主要：http://news.livedoor.com/topics/rss/top.xml
- 国内：http://news.livedoor.com/topics/rss/dom.xml
- 海外：http://news.livedoor.com/topics/rss/int.xml
- IT 経済：http://news.livedoor.com/topics/rss/eco.xml
- 芸能：http://news.livedoor.com/topics/rss/ent.xml
- スポーツ：http://news.livedoor.com/topics/rss/spo.xml
- 映画：http://news.livedoor.com/rss/summary/52.xml
- グルメ：http://news.livedoor.com/topics/rss/gourmet.xml
- 女子：http://news.livedoor.com/topics/rss/love.xml
- トレンド：http://news.livedoor.com/topics/rss/trend.xml

### その他の機能
- ニュース記事を表示する場合，その記事と関連する記事（リンク）を3つ表示できる

### インストールの手順

1. ソースコードをダウンロードする、あるいは、gitでcloneする。

2. LivedoorRSSReader.xcworkspaceをXcodeで開く。
([Xcode](https://developer.apple.com/jp/xcode/index.html)はiOSアプリ開発用の標準IDEで、まだインストールされていない場合、事前にインストールしてください。)
> 注意：類似するファイル名LivedoorRSSReader.xcodeprojと間違えないようにしてください。間違ったら、各ライブラリがプロジェクトにリンクされないので、コンパイル時エラーになります。

3. Xcodeでビルドして、iphoneのシミュレーターあるいは実機で実行する。
> 注意：実機で実行する場合、[ここ](http://blog.gclue.jp/2013/06/xcode.html)に説明されたとおりの設定が必要です。シミュレーターの場合、気にしなくて良いです。