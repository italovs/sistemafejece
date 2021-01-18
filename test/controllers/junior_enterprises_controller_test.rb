require 'test_helper'

class JuniorEnterprisesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @junior_enterprise = junior_enterprises(:one)
  end

  test "should get index" do
    get junior_enterprises_url
    assert_response :success
  end

  test "should get new" do
    get new_junior_enterprise_url
    assert_response :success
  end

  test "should create junior_enterprise" do
    assert_difference('JuniorEnterprise.count') do
      post junior_enterprises_url, params: { junior_enterprise: { description: @junior_enterprise.description, name: @junior_enterprise.name } }
    end

    assert_redirected_to junior_enterprise_url(JuniorEnterprise.last)
  end

  test "should show junior_enterprise" do
    get junior_enterprise_url(@junior_enterprise)
    assert_response :success
  end

  test "should get edit" do
    get edit_junior_enterprise_url(@junior_enterprise)
    assert_response :success
  end

  test "should update junior_enterprise" do
    patch junior_enterprise_url(@junior_enterprise), params: { junior_enterprise: { description: @junior_enterprise.description, name: @junior_enterprise.name } }
    assert_redirected_to junior_enterprise_url(@junior_enterprise)
  end

  test "should destroy junior_enterprise" do
    assert_difference('JuniorEnterprise.count', -1) do
      delete junior_enterprise_url(@junior_enterprise)
    end

    assert_redirected_to junior_enterprises_url
  end
end
