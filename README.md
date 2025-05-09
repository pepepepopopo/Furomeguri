◽️画面遷移図リンク
Figma：https://www.figma.com/design/6uGxQ5lEgW61YQVW6O0t5u/Furomeguri?node-id=0-1&t=xkYWUInvvAzlEafK-1

◽️画面遷移図リンク
https://gyazo.com/60109cc78abf5cf2d087ea4f5906e187

■サービス概要
Furomeguriは温泉旅行に特化した行先選定と旅程作成が可能な旅行アプリです。
ユーザーは温泉施設、周辺施設を比較し、旅程をたてることができます。

■ このサービスへの思い・作りたい理由
私は旅行する時必ず温泉がある場所を選んだり、毎週温泉に行くほどの温泉好きです。
しかし温泉施設を目的とした旅行をする際、旅程の作成に複数のサービスを併用する必要があり、効率的とは言えませんでした。
そこで、温泉旅行に特化し、マップ上での施設選定から旅程作成までを一つのアプリで完結できる仕組みを提供したいと考えました。

■ ユーザー層について
*温泉旅行を好んで行うユーザー
**観光地を積極的に巡る旅行ではなく、温泉でゆっくり過ごすことを目的とするユーザーを想定しています。
  本アプリは、温泉およびその周辺施設に特化し、旅程作成を一貫して行える設計となっており、
  このようなユーザーにとって利便性が高いと考えられます。

■サービスの利用イメージ
1. アプリ内のマップ機能を用いて、旅行先となる温泉地を選定します。
2. 温泉施設を絞り込み検索し、見た目や予算などの条件を考慮して宿泊先を決定します。
3. 周辺施設を検索して行き先を追加し、当日の旅程を作成します。

■ ユーザーの獲得について
各種SNSを活用し、想定するユーザー層に向けて、実際のアプリ使用画面（スクリーンショット）を用いた投稿を行います。
使用感や機能が伝わる具体的なビジュアルコンテンツにより、興味・関心の訴求を図ります。

■ サービスの差別化ポイント・推しポイント
既存の温泉系アプリには、温泉地をマップ上に表示する「温泉マップ」のようなサービスがありますが、
旅程作成機能を備えた温泉特化型アプリは存在していません。
本アプリでは、温泉施設のマップ表示に加え、選定から旅程の作成までを一貫して行える点を差別化の要素としています。

■ 機能候補
*MVPリリースまでに作成したい機能
**温泉施設マップ機能
**検索機能
***温泉施設：キーワード・予算・施設条件（駐車場、露天風呂、源泉かけ流しなど）
***周辺施設の検索は飲食店と観光地を掲載
***飲食店：キーワード・ジャンルでの絞り込み
***観光地：マップ上のレイヤー切替により表示（例：城・景観地）
**温泉施設・宿泊施設の基本情報表示（写真・住所・価格帯等）
**旅程作成・編集機能

*本リリースまでに作成したい機能
**レコメンド機能
**マルチ検索やオートコンプリートによる検索性向上
**行った場所のお気に入り、メモ機能

■ 機能の実装方針予定
Google Maps API：マップ表示・位置情報取得・観光地表示
楽天トラベル API：温泉宿泊施設の取得・表示 //じゃらんWEBサービスは新規受付を停止していました
リクルート Webサービス API：飲食店情報の取得