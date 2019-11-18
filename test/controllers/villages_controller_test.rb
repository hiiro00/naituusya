require 'test_helper'

class VillagesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get villages_show_url
    assert_response :success
  end

end
