# アプリ「駒場教室検索」

## 概要
本郷テックガレージ主催「Project Fund」応募作品として制作されたアプリです．

キャンパスに通う機会が少なく道を覚えられないという課題意識から，
教室名を入力するとその教室がある建物名と，そこまでの案内をしてくれるアプリを制作しました．

## 環境
- Flutter 2.10.0
- Dart 2.16.0
- DevTools 2.9.2

## テスト
このアプリはGoogle Cloud Platform のAPIを使用しているため，テストするにはそのAPIKeyが必要になります．
`lib`ディレクトリ配下に`apikey.dart`ファイルを作り，
```dart:apikey.dart
String api_key = "your_api_key";
```
と記述してください．`your_api_key`の部分には自分で取得したAPIKeyを入力してください．

また，`android`ディレクトリ配下の`local.properties`ファイルに
```dart:android/local.properties
...
MAPS_API_KEY=your_api_key//これを追加
```
の一行を追加してください．
一部packageがnull safetyに対応していないため，実行コマンドは
`flutter run --no-sound-null-safety`でお願いします．

参考資料 : [Flutterでの開発でAPIKeyを隠してGithubにあげる方法](https://qiita.com/WMs784/items/4b22305e013c44896a4b#libmaindart%E3%81%B8%E3%81%AE%E6%9B%B8%E3%81%8D%E5%87%BA%E3%81%97)
