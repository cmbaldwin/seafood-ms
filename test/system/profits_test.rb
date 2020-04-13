require "application_system_test_case"

class ProfitsTest < ApplicationSystemTestCase
  setup do
    @profit = profits(:one)
  end

  test "visiting the index" do
    visit profits_url
    assert_selector "h1", text: "Profits"
  end

  test "creating a Profit" do
    visit profits_url
    click_on "New Profit"

    click_on "Create Profit"

    assert_text "Profit was successfully created"
    click_on "Back"
  end

  test "updating a Profit" do
    visit profits_url
    click_on "Edit", match: :first

    click_on "Update Profit"

    assert_text "Profit was successfully updated"
    click_on "Back"
  end

  test "destroying a Profit" do
    visit profits_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Profit was successfully destroyed"
  end
end
