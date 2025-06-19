require "test_helper"

class ItineraryBlocksControllerTest < ActionDispatch::IntegrationTest
  skip
  test "should get create" do
    get itinerary_itinerary_blocks_url(@itinerary)
    assert_response :success
  end

  test "should get destroy" do
    get itinerary_itinerary_block_url(@itinerary, @block)
    assert_response :success
  end
end
