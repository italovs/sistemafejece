require "application_system_test_case"

class JuniorEnterprisesTest < ApplicationSystemTestCase
  setup do
    @junior_enterprise = junior_enterprises(:one)
  end

  test "visiting the index" do
    visit junior_enterprises_url
    assert_selector "h1", text: "Junior Enterprises"
  end

  test "creating a Junior enterprise" do
    visit junior_enterprises_url
    click_on "New Junior Enterprise"

    fill_in "Description", with: @junior_enterprise.description
    fill_in "Name", with: @junior_enterprise.name
    click_on "Create Junior enterprise"

    assert_text "Junior enterprise was successfully created"
    click_on "Back"
  end

  test "updating a Junior enterprise" do
    visit junior_enterprises_url
    click_on "Edit", match: :first

    fill_in "Description", with: @junior_enterprise.description
    fill_in "Name", with: @junior_enterprise.name
    click_on "Update Junior enterprise"

    assert_text "Junior enterprise was successfully updated"
    click_on "Back"
  end

  test "destroying a Junior enterprise" do
    visit junior_enterprises_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Junior enterprise was successfully destroyed"
  end
end
