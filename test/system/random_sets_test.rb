require "application_system_test_case"

class RandomSetsTest < ApplicationSystemTestCase
  setup do
    @random_set = random_sets(:one)
  end

  test "visiting the index" do
    visit random_sets_url
    assert_selector "h1", text: "Random sets"
  end

  test "should create random set" do
    visit random_sets_url
    click_on "New random set"

    fill_in "Data", with: @random_set.data
    fill_in "Name", with: @random_set.name
    fill_in "Parent", with: @random_set.parent
    click_on "Create Random set"

    assert_text "Random set was successfully created"
    click_on "Back"
  end

  test "should update Random set" do
    visit random_set_url(@random_set)
    click_on "Edit this random set", match: :first

    fill_in "Data", with: @random_set.data
    fill_in "Name", with: @random_set.name
    fill_in "Parent", with: @random_set.parent
    click_on "Update Random set"

    assert_text "Random set was successfully updated"
    click_on "Back"
  end

  test "should destroy Random set" do
    visit random_set_url(@random_set)
    click_on "Destroy this random set", match: :first

    assert_text "Random set was successfully destroyed"
  end
end
