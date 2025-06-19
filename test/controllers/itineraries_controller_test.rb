require "test_helper"

class ItinerariesControllerTest < ActionDispatch::IntegrationTest

  test "should get index" do
    skip
    get itineraries_url
    assert_response :success
  end

  test "should get new" do
    skip
    get new_itinerary_url
    assert_response :success
  end

  test "should get create" do
    skip
    post new_itinerary_url
    assert_response :success
  end

  test "should get edit" do
    skip
    get edit_itinerary_url(@itinerary)
    assert_response :success
  end

  test "should get update" do
    skip
    patch itinerary_url(@itinerary)
    assert_response :success
  end

  test "should get show" do
    skip
    get itinerary_url(@itinerary)
    assert_response :success
  end
end
