require "test_helper"

class RandomSetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @random_set = random_sets(:one)
  end

  test "should get index" do
    get random_sets_url
    assert_response :success
  end

  test "should get new" do
    get new_random_set_url
    assert_response :success
  end

  test "should create random_set" do
    assert_difference("RandomSet.count") do
      post random_sets_url, params: { random_set: { data: @random_set.data, name: @random_set.name, parent: @random_set.parent } }
    end

    assert_redirected_to random_set_url(RandomSet.last)
  end

  test "should show random_set" do
    get random_set_url(@random_set)
    assert_response :success
  end

  test "should get edit" do
    get edit_random_set_url(@random_set)
    assert_response :success
  end

  test "should update random_set" do
    patch random_set_url(@random_set), params: { random_set: { data: @random_set.data, name: @random_set.name, parent: @random_set.parent } }
    assert_redirected_to random_set_url(@random_set)
  end

  test "should destroy random_set" do
    assert_difference("RandomSet.count", -1) do
      delete random_set_url(@random_set)
    end

    assert_redirected_to random_sets_url
  end
end
