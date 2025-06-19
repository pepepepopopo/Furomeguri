require "test_helper"

class ItinerariesControllerTest < ActionDispatch::IntegrationTest

  test "should get index" do
    skip "test未書き換え"
    get itineraries_url
    assert_response :success
  end

  test "should get new" do
    skip "test未書き換え"
    get new_itinerary_url
    assert_response :success
  end

  test "should get create" do
    skip "test未書き換え"
    post new_itinerary_url
    assert_response :success
  end

  test "should get edit" do
    skip "test未書き換え"
    get edit_itinerary_url(@itinerary)
    assert_response :success
  end

  test "should get update" do
    skip "test未書き換え"
    patch itinerary_url(@itinerary)
    assert_response :success
  end

  test "should get show" do
    skip "test未書き換え"
    get itinerary_url(@itinerary)
    assert_response :success
  end
end
