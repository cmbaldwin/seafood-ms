require "application_system_test_case"

class OysterInvoicesTest < ApplicationSystemTestCase
  setup do
    @oyster_invoice = oyster_invoices(:one)
  end

  test "visiting the index" do
    visit oyster_invoices_url
    assert_selector "h1", text: "Oyster Invoices"
  end

  test "creating a Oyster invoice" do
    visit oyster_invoices_url
    click_on "New Oyster Invoice"

    fill_in "Aioi all pdf", with: @oyster_invoice.aioi_all_pdf
    fill_in "Aioi seperated pdf", with: @oyster_invoice.aioi_seperated_pdf
    check "Completed" if @oyster_invoice.completed
    fill_in "Data", with: @oyster_invoice.data
    fill_in "Emails", with: @oyster_invoice.emails
    fill_in "End date", with: @oyster_invoice.end_date
    fill_in "Sakoshi all pdf", with: @oyster_invoice.sakoshi_all_pdf
    fill_in "Sakoshi seperated pdf", with: @oyster_invoice.sakoshi_seperated_pdf
    fill_in "Start date", with: @oyster_invoice.start_date
    click_on "Create Oyster invoice"

    assert_text "Oyster invoice was successfully created"
    click_on "Back"
  end

  test "updating a Oyster invoice" do
    visit oyster_invoices_url
    click_on "Edit", match: :first

    fill_in "Aioi all pdf", with: @oyster_invoice.aioi_all_pdf
    fill_in "Aioi seperated pdf", with: @oyster_invoice.aioi_seperated_pdf
    check "Completed" if @oyster_invoice.completed
    fill_in "Data", with: @oyster_invoice.data
    fill_in "Emails", with: @oyster_invoice.emails
    fill_in "End date", with: @oyster_invoice.end_date
    fill_in "Sakoshi all pdf", with: @oyster_invoice.sakoshi_all_pdf
    fill_in "Sakoshi seperated pdf", with: @oyster_invoice.sakoshi_seperated_pdf
    fill_in "Start date", with: @oyster_invoice.start_date
    click_on "Update Oyster invoice"

    assert_text "Oyster invoice was successfully updated"
    click_on "Back"
  end

  test "destroying a Oyster invoice" do
    visit oyster_invoices_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Oyster invoice was successfully destroyed"
  end
end
