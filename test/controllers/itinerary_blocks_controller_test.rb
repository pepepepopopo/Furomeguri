require "test_helper"

class ItineraryBlocksControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get itinerary_blocks_url
    assert_response :success
  end

  test "should get destroy" do
    get itinerary_blocks_url(block)
    assert_response :success
  end
end
