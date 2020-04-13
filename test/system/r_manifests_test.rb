require "application_system_test_case"

class RManifestsTest < ApplicationSystemTestCase
  setup do
    @r_manifest = r_manifests(:one)
  end

  test "visiting the index" do
    visit r_manifests_url
    assert_selector "h1", text: "R Manifests"
  end

  test "creating a R manifest" do
    visit r_manifests_url
    click_on "New R Manifest"

    fill_in "Orders hash", with: @r_manifest.orders_hash
    click_on "Create R manifest"

    assert_text "R manifest was successfully created"
    click_on "Back"
  end

  test "updating a R manifest" do
    visit r_manifests_url
    click_on "Edit", match: :first

    fill_in "Orders hash", with: @r_manifest.orders_hash
    click_on "Update R manifest"

    assert_text "R manifest was successfully updated"
    click_on "Back"
  end

  test "destroying a R manifest" do
    visit r_manifests_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "R manifest was successfully destroyed"
  end
end
