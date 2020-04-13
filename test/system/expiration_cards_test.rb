require "application_system_test_case"

class ExpirationCardsTest < ApplicationSystemTestCase
  setup do
    @expiration_card = expiration_cards(:one)
  end

  test "visiting the index" do
    visit expiration_cards_url
    assert_selector "h1", text: "Expiration Cards"
  end

  test "creating a Expiration card" do
    visit expiration_cards_url
    click_on "New Expiration Card"

    fill_in "Consumption restrictions", with: @expiration_card.consumption_restrictions
    fill_in "Expiration date", with: @expiration_card.expiration_date
    fill_in "Ingredient source", with: @expiration_card.ingredient_source
    fill_in "Manufactuered date", with: @expiration_card.manufactuered_date
    fill_in "Manufacturer", with: @expiration_card.manufacturer
    fill_in "Manufacturer address", with: @expiration_card.manufacturer_address
    fill_in "Product name", with: @expiration_card.product_name
    click_on "Create Expiration card"

    assert_text "Expiration card was successfully created"
    click_on "Back"
  end

  test "updating a Expiration card" do
    visit expiration_cards_url
    click_on "Edit", match: :first

    fill_in "Consumption restrictions", with: @expiration_card.consumption_restrictions
    fill_in "Expiration date", with: @expiration_card.expiration_date
    fill_in "Ingredient source", with: @expiration_card.ingredient_source
    fill_in "Manufactuered date", with: @expiration_card.manufactuered_date
    fill_in "Manufacturer", with: @expiration_card.manufacturer
    fill_in "Manufacturer address", with: @expiration_card.manufacturer_address
    fill_in "Product name", with: @expiration_card.product_name
    click_on "Update Expiration card"

    assert_text "Expiration card was successfully updated"
    click_on "Back"
  end

  test "destroying a Expiration card" do
    visit expiration_cards_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Expiration card was successfully destroyed"
  end
end
