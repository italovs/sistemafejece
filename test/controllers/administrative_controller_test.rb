# frozen_string_literal: true

require 'test_helper'

class AdministrativeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get administrative_index_url
    assert_response :success
  end

end
