require "test_helper"

class ItineraryBlocksControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get create_itinerary_blocks_url
    assert_response :success
  end

  test "should get destroy" do
    get destroy_itinerary_blocks_url
    assert_response :success
  end
end
