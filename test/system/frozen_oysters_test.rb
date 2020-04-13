require "application_system_test_case"

class FrozenOystersTest < ApplicationSystemTestCase
  setup do
    @frozen_oyster = frozen_oysters(:one)
  end

  test "visiting the index" do
    visit frozen_oysters_url
    assert_selector "h1", text: "Frozen Oysters"
  end

  test "creating a Frozen oyster" do
    visit frozen_oysters_url
    click_on "New Frozen Oyster"

    fill_in "Finished packs", with: @frozen_oyster.finished_packs
    fill_in "Frozen l", with: @frozen_oyster.frozen_l
    fill_in "Frozen ll", with: @frozen_oyster.frozen_ll
    fill_in "Hyogo raw", with: @frozen_oyster.hyogo_raw
    fill_in "Sakoshi raw", with: @frozen_oyster.sakoshi_raw
    click_on "Create Frozen oyster"

    assert_text "Frozen oyster was successfully created"
    click_on "Back"
  end

  test "updating a Frozen oyster" do
    visit frozen_oysters_url
    click_on "Edit", match: :first

    fill_in "Finished packs", with: @frozen_oyster.finished_packs
    fill_in "Frozen l", with: @frozen_oyster.frozen_l
    fill_in "Frozen ll", with: @frozen_oyster.frozen_ll
    fill_in "Hyogo raw", with: @frozen_oyster.hyogo_raw
    fill_in "Sakoshi raw", with: @frozen_oyster.sakoshi_raw
    click_on "Update Frozen oyster"

    assert_text "Frozen oyster was successfully updated"
    click_on "Back"
  end

  test "destroying a Frozen oyster" do
    visit frozen_oysters_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Frozen oyster was successfully destroyed"
  end
end
