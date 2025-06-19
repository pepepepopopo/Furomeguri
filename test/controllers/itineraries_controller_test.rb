require "test_helper"

class ItinerariesControllerTest < ActionDispatch::IntegrationTest

  test "should get index", skip:"test未書き換え" do
    get itineraries_url
    assert_response :success
  end

  test "should get new", skip:"test未書き換え" do
    get new_itinerary_url
    assert_response :success
  end

  test "should get create", skip:"test未書き換え" do
    post new_itinerary_url
    assert_response :success
  end

  test "should get edit", skip:"test未書き換え" do
    get edit_itinerary_url(@itinerary)
    assert_response :success
  end

  test "should get update", skip:"test未書き換え" do
    patch itinerary_url(@itinerary)
    assert_response :success
  end

  test "should get show", skip:"test未書き換え" do
    get itinerary_url(@itinerary)
    assert_response :success
  end
end
