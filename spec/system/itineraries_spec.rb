require 'rails_helper'

RSpec.describe "Itineraries", type: :system do
  include LoginMacros
  describe "ログイン後" do
    let(:user) { create(:user) }
    before { login_as(user)}
    context "新規旅行計画を作成" do
      it "旅行計画が作成される" do
        visit new_itinerary_path
        fill_in "タイトル", with: "タイトル"
        fill_in "サブタイトル", with: "サブタイトル"
        click_button "Let's 旅行作り!"
        expect(page).to have_content "新規旅行計画を作成しました"
      end
    end
    # context "旅行計画を編集できる" do
    #   let!(:itinerary) { create(:itinerary, user: user) }
    #   let!(:itinerary_block) { create(:itinerary_block, itinerary: itinerary)}
    #   it "編集ボタンで編集画面" do
    #     visit itineraries_path
    #     click_link "編集"

    #   end
    # end
    context "旅行計画を削除できる" do
      let!(:itinerary) { create(:itinerary, user: user) }
      it "削除ボタン押下で旅行計画が削除される" do
        visit itineraries_path
        accept_alert do
          click_link "削除"
        end
        expect(page).to have_content "削除しました"
      end
    end
  end
end
