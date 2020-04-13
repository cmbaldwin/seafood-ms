require "application_system_test_case"

class OysterSuppliesTest < ApplicationSystemTestCase
  setup do
    @oyster_supply = oyster_supplies(:one)
  end

  test "visiting the index" do
    visit oyster_supplies_url
    assert_selector "h1", text: "Oyster Supplies"
  end

  test "creating a Oyster supply" do
    visit oyster_supplies_url
    click_on "New Oyster Supply"

    fill_in "Oysters", with: @oyster_supply.oysters
    fill_in "Supply date", with: @oyster_supply.supply_date
    click_on "Create Oyster supply"

    assert_text "Oyster supply was successfully created"
    click_on "Back"
  end

  test "updating a Oyster supply" do
    visit oyster_supplies_url
    click_on "Edit", match: :first

    fill_in "Oysters", with: @oyster_supply.oysters
    fill_in "Supply date", with: @oyster_supply.supply_date
    click_on "Update Oyster supply"

    assert_text "Oyster supply was successfully updated"
    click_on "Back"
  end

  test "destroying a Oyster supply" do
    visit oyster_supplies_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Oyster supply was successfully destroyed"
  end
end
