module MapsHelper
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

  def food_budget_options
    [
      { code: 'B009', name: '～500円' },
      { code: 'B010', name: '501～1000円' },
      { code: 'B011', name: '1001～1500円' },
      { code: 'B001', name: '1501～2000円' },
      { code: 'B002', name: '2001～3000円' },
      { code: 'B003', name: '3001～4000円' },
      { code: 'B008', name: '4001～5000円' },
      { code: 'B004', name: '5001～7000円' },
      { code: 'B005', name: '7001～10000円' },
      { code: 'B006', name: '10001～15000円' },
      { code: 'B012', name: '15001～20000円' },
      { code: 'B013', name: '20001～30000円' },
      { code: 'B014', name: '30001円～' }
    ]
  end
end
