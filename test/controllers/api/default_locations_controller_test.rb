require "test_helper"

class Api::DefaultLocationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_default_locations_index_url
    assert_response :success
  end
end
