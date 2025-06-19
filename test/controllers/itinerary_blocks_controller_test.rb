require "test_helper"

class ItineraryBlocksControllerTest < ActionDispatch::IntegrationTest
  test "should get create", skip: "test未書き換え" do
    get itinerary_itinerary_blocks_url(@itinerary)
    assert_response :success
  end

  test "should get destroy", skip: "test未書き換え" do
    get itinerary_itinerary_block_url(@itinerary, @block)
    assert_response :success
  end
end
