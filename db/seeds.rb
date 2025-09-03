# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

DefaultLocation.create!([
  { name: "登別(北海道)", lat: 42.495801, lng: 141.147003 },
  { name: "熱海(静岡県)", lat: 35.099323, lng: 139.077021 },
  { name: "箱根(神奈川県)", lat: 35.24343940136944, lng: 139.0202909532175 },
  { name: "草津(群馬県)", lat: 36.62303436838449, lng: 138.59697281955727 },
  { name: "下呂(岐阜県)", lat: 35.80783558290318, lng: 137.2417343342305 },
  { name: "有馬(兵庫県)", lat: 34.796697, lng: 135.248605 },
  { name: "道後(愛媛県)", lat: 33.852328, lng: 132.785225 },
  { name: "別府(大分県)", lat: 33.31614938103781, lng: 131.47085516768604 },
  { name: "由布院(大分県)", lat: 33.263889, lng: 131.359722 }
])
