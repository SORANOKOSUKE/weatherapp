# WeatherAppについて
## **作成にあたって**
* 要件
 - HTTP通信を利用したアプリの作成
 - アプリ起動時，地域を選択→ 選択した地域に従って天気を取得する．
 - (Alamofire と　Combineを使用すること)
 
* 実装した機能
 - MapViewから緯度，経度を取得し，TableViewに天気予報(5日間)を表示させる
 - 2ページ目にはスクロールビューから地域を選択し，TableViewに天気予報(5日間)を表示させる．
 - NewsAPIからNew情報を読み込んで，画像と記事，また外部リンクでsafariの起動
 
*　実装していない項目
 - ページ間のデータの受け渡し
 - マイページの作成　など
 

## **構成**


```
App
├── View:View controllerやmapViewなど，view関連を格納
│
├── ViewModel: Viewとビジネスロジック間のデータの橋渡しを担当
│
├── Repository: データソースを変更させるコードを置いてます．
│   ├── Manager: APIの取得関係のコードを置いてます．
│   └── TableSource: Tabledataの変形やdelegate関係などを置いてます．
└── Data:データの箱や初期値を置いています． 
```

 
## **構成説明**

#### mapViewDidPress
* ViewController→WeatherViewModel
* SecondViewController→SecondViewModel

ViewControllerは地図情報から天気予報を取得する．

SecondViewControllerはPickerViewから都市を選択し，天気予報を取得する．
SecondViewControllerは他にNewAPIからニュース情報を取得し表示しする．

ともに，WeatherManagerで天気予報をAPI取得し，TableDataSourceに連携している．

* WeatherManager

AlamofieでAPIからJsonコードを取得している．データの型は，datasourceに格納している．

* NewsManager

AlamofieでAPIからJsonコードを取得している．データの型は，datasourceに格納している．
NewsManagerはNewsAPIから取得したurlから再度ニュース画像情報を取得している．

* APIは(https://paiza.hatenablog.com/entry/2021/11/04/130000 "Open-Meteo")を利用
       
## **所感**
* できる限り重複をなくそうとしたり，シンプルな構成にしようとしましたが，まだまだシンプルにできる感じがあります．
