# ♨️プロジェクト名：[風呂めぐり](https://furomeguri-1.onrender.com)
![ogp (1)](https://github.com/user-attachments/assets/345087e7-6b13-4184-87ea-2908494eefe5)

# 📄サービス概要
Furomeguriは温泉旅行に特化した行先選定と旅程作成が可能な旅行アプリです。
温泉施設を目的とした旅行をする際、旅程の作成に複数のサービスを併用する必要があり、効率的とは言えませんでした。
そこで、温泉旅行に特化し、マップ上での施設選定から旅程作成までを一つのアプリで完結できる仕組みを提供したいと考えました。
観光地を積極的に巡る旅行ではなく、温泉でゆっくり過ごすことを目的とするユーザーを想定しています。
本アプリは、温泉およびその周辺施設に特化し、旅程作成を一貫して行える設計となっております。

# 🔧使用技術
| **カテゴリ** | **技術内容** |
| --- | --- |
| サーバーサイド  | ruby 3.2.3・Ruby on Rails 7.2.2.1  |
| フロントエンド  | Ruby on Rails・JavaScript  |
| CSSフレームワーク  | Tailwindcss + daisyUI  |
| 外部 API  | Google map API・Rakuten travel API・リクルートWEBサービス  |
| データベースサーバー  | PostgreSQL  |
| アプリケーションサーバー  | Render  |
| バージョン管理ツール  | Git  |
| CI/CD  | Github Actions/rubocop  |
| 環境構築  | Docker  |

## サービスURL：https://furomeguri-1.onrender.com  

・ゲストユーザー  
【メールアドレス】furomeguri-test-1@example.com  
【パスワード」password  

# 💻主要な機能
| **🔑ユーザー登録・ログイン機能** |
| --- |
| ![Adobe Express - Furomeguri - Google Chrome 2025-10-15 20-28-44](https://github.com/user-attachments/assets/fa8c7870-3985-45cd-8799-8b59847c89cb) |
| 『メールアドレス』『パスワード』『確認用パスワード』を入力してユーザー登録を行います。ユーザー登録後は、自動的にログイン処理が行われるようになっており、そのまま直ぐにサービスを利用する事が出来ます。<br>また、Googleアカウントを用いてGoogleログイン認証を行う事も可能です。 |

| **🧳旅行計画作成機能** |
| --- |
| ![Adobe Express - Furomeguri - Google Chrome 2025-10-15 20-30-32](https://github.com/user-attachments/assets/0aee3c3b-7b7e-424a-88d1-68284f6d4591) |
| 旅行計画作成ボタンからタイトルとサブタイトルを入れることで旅行計画が作成できます。<br>タイトルは必須としていますがタイトルを後で決める方のために無記入で作成されると「タイトル未定」として作成されます。|

| **♨️旅行先検索機能** |
| --- |
| ![Adobe Express - Furomeguri - Google Chrome 2025-10-15 23-31-09](https://github.com/user-attachments/assets/cc4536a8-41cd-488b-a042-2ff4ebc0b994) |
| 検索バーから旅行先を検索することが出来ます。<br>検索バーは3つのタブに分かれており、それぞれの検索バーででジャンルの異なった旅行先を検索することが来ます。<br>旅館と飲食店の検索はこだわり条件を追加し、より希望に沿った場所を検索できるようにしています|

| **👟旅行計画追加機能** |
| --- |
| ![Adobe Express - Furomeguri - Google Chrome 2025-10-15 23-56-27 (1)](https://github.com/user-attachments/assets/377ca85d-7100-478b-b680-1bd00083d87f) |
| 検索後にヒットした地点にピンが立ち、情報ウィンドウに旅程追加ボタンがあります。<be>旅程追加ボタンをクリックすることでサイドバーに追加されていきます。<br>追加された旅行計画はドラッグアンドドロップで並べ替え可能です。|
