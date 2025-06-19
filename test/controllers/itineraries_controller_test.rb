require "test_helper"

class ItinerariesControllerTest < ActionDispatch::IntegrationTest
  skip
  setup do
    @itinerary = itineraries(:one)
  end

  test "should get index" do
    get itineraries_url
    assert_response :success
  end

  test "should get new" do
    get new_itinerary_url
    assert_response :success
  end

  test "should get create" do
    post new_itinerary_url
    assert_response :success
  end

  test "should get edit" do
    get edit_itinerary_url(@itinerary)
    assert_response :success
  end

  test "should get update" do
    patch itinerary_url(@itinerary)
    assert_response :success
  end

  test "should get show" do
    get itinerary_url(@itinerary)
    assert_response :success
  end
end
