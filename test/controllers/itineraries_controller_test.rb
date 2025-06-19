require "test_helper"

class ItinerariesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get itineraries_url
    assert_response :success
  end

  test "should get new" do
    get new_itinerary_url
    assert_response :success
  end

  test "should get create" do
    post itineraries_url, params: { itinerary: { title: "テスト", subtitle: "テストサブ", user_id: @itinerary.user_id } }
    assert_response :success
  end

  test "should get edit" do
    get edit_itinerary_url(@itinerary)
    assert_response :success
  end

  test "should get update" do
    get itinerary_url(@itinerary)
    assert_response :success
  end

  test "should get show" do
    get itinerary_url(@itinerary)
    assert_response :success
  end
end
