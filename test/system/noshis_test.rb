require "application_system_test_case"

class NoshisTest < ApplicationSystemTestCase
  setup do
    @noshi = noshis(:one)
  end

  test "visiting the index" do
    visit noshis_url
    assert_selector "h1", text: "Noshis"
  end

  test "creating a Noshi" do
    visit noshis_url
    click_on "New Noshi"

    fill_in "Namae", with: @noshi.namae
    fill_in "Ntype", with: @noshi.ntype
    fill_in "Omotegaki", with: @noshi.omotegaki
    click_on "Create Noshi"

    assert_text "Noshi was successfully created"
    click_on "Back"
  end

  test "updating a Noshi" do
    visit noshis_url
    click_on "Edit", match: :first

    fill_in "Namae", with: @noshi.namae
    fill_in "Ntype", with: @noshi.ntype
    fill_in "Omotegaki", with: @noshi.omotegaki
    click_on "Update Noshi"

    assert_text "Noshi was successfully updated"
    click_on "Back"
  end

  test "destroying a Noshi" do
    visit noshis_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Noshi was successfully destroyed"
  end
end
