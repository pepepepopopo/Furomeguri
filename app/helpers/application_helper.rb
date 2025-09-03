module ApplicationHelper
  def default_meta_tags
    {
      site: "風呂めぐり",
      title: "風呂めぐり",
      reverse: true,
      charset: "utf-8",
      description: "旅行先の選定から予定作成までを一貫してアプリ上でできます！",
      keywords: "温泉,旅行,旅行計画",
      canonical: request.original_url,
      separator: "|",
      # icon: [
      #   { href: image_url("logo.png") },
      #   { href: image_url("top_image.png"), rel: "apple-touch-icon", sizes: "180x180", type: "image/png" },
      # ],
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: "website",
        url: request.original_url,
        image: image_url("ogp.jpg"), # 配置するパスやファイル名によって変更する
        local: "ja-JP"
      },
      twitter: {
        card: "summary_large_image", # Twitterで表示する場合は大きいカードに変更
        site: "@あなたのツイッターアカウント", # アプリの公式Twitterアカウントがあれば、アカウント名を記載
        image: image_url("ogp.jpg") # 配置するパスやファイル名によって変更
      }
    }
  end

  def budget_price_options
    prices = [
      1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10_000, # 1000円間隔
      12_000, 14_000, 16_000, 18_000, 20_000, # 2000円間隔
      30_000, 40_000, 50_000, 100_000
    ]
    {
      min: prices,
      max: prices
    }
  end
end
