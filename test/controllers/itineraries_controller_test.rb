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
    get create_itinerary_url
    assert_response :success
  end

  test "should get edit" do
    get edit_itinerary_url
    assert_response :success
  end

  test "should get update" do
    get update_itinerary_url
    assert_response :success
  end

  test "should get show" do
    get show_itinerary_url
    assert_response :success
  end
end
