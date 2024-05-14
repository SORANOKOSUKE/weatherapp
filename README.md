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
 - マイページの作成
 - データの保存　　など
 
## **関数の説明**

#### mapViewDidPress
* mapViewDidPress MapViewを押した時に，senderが値(sender.location(in: view))を持っている．
* annotation　// ピンを指すMKPointAnnotation()をインスタンス化
* if !pinAnnotations.isEmpty {　//古いピンを削除
* mapView.addAnnotation(annotation)　//表示
            

#### getURL
* mapViewDidPressから緯度経度を取得し，APIを取得するためのURLを返す．
* APIは(https://paiza.hatenablog.com/entry/2021/11/04/130000 "Open-Meteo")を利用

            
            
## **所感**
* SharedPreferencesでget,putで操作し，保存は可能であったが，データ容量や画像等の保存方法は外部データベースの学習が必要。
