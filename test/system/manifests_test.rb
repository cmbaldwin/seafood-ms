require "application_system_test_case"

class ManifestsTest < ApplicationSystemTestCase
  setup do
    @manifest = manifests(:one)
  end

  test "visiting the index" do
    visit manifests_url
    assert_selector "h1", text: "Manifests"
  end

  test "creating a Manifest" do
    visit manifests_url
    click_on "New Manifest"

    fill_in "Infomart orders", with: @manifest.infomart_orders
    fill_in "Online shop orders", with: @manifest.online_shop_orders
    fill_in "Sales date", with: @manifest.sales_date
    click_on "Create Manifest"

    assert_text "Manifest was successfully created"
    click_on "Back"
  end

  test "updating a Manifest" do
    visit manifests_url
    click_on "Edit", match: :first

    fill_in "Infomart orders", with: @manifest.infomart_orders
    fill_in "Online shop orders", with: @manifest.online_shop_orders
    fill_in "Sales date", with: @manifest.sales_date
    click_on "Update Manifest"

    assert_text "Manifest was successfully updated"
    click_on "Back"
  end

  test "destroying a Manifest" do
    visit manifests_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Manifest was successfully destroyed"
  end
end
