require "test_helper"

class ItineraryBlocksControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get itinerary_blocks_create_url
    assert_response :success
  end

  test "should get destroy" do
    get itinerary_blocks_destroy_url
    assert_response :success
  end
end
