require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーションチェック"
    it "すべてのバリデーションが機能しているか" do
      user = build(:user)
      expect(user).to be_valid
      expect(user.errors).to be_empty
    end

    it "emailがない場合にinvalidになる" do
      user_without_email = build(:user, email:"")
      expect(user_without_email).to be_invalid
    end

    it "emailに被りがある場合invalidになる" do
      user = create(:user)
      user_with_another_email = build(:user, email: user.email)
      expect(user_with_another_email).to be_invalid
    end
end
