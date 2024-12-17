require "test_helper"

class LotteriesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get lotteries_new_url
    assert_response :success
  end

  test "should get create" do
    get lotteries_create_url
    assert_response :success
  end

  test "should get edit" do
    get lotteries_edit_url
    assert_response :success
  end

  test "should get update" do
    get lotteries_update_url
    assert_response :success
  end

  test "should get destroy" do
    get lotteries_destroy_url
    assert_response :success
  end
end
