require "test_helper"

class Api::DefaultLocationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get '/api/default_locations'
    assert_response :success
  end
end
