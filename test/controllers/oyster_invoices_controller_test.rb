require 'test_helper'

class OysterInvoicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @oyster_invoice = oyster_invoices(:one)
  end

  test "should get index" do
    get oyster_invoices_url
    assert_response :success
  end

  test "should get new" do
    get new_oyster_invoice_url
    assert_response :success
  end

  test "should create oyster_invoice" do
    assert_difference('OysterInvoice.count') do
      post oyster_invoices_url, params: { oyster_invoice: { aioi_all_pdf: @oyster_invoice.aioi_all_pdf, aioi_seperated_pdf: @oyster_invoice.aioi_seperated_pdf, completed: @oyster_invoice.completed, data: @oyster_invoice.data, emails: @oyster_invoice.emails, end_date: @oyster_invoice.end_date, sakoshi_all_pdf: @oyster_invoice.sakoshi_all_pdf, sakoshi_seperated_pdf: @oyster_invoice.sakoshi_seperated_pdf, start_date: @oyster_invoice.start_date } }
    end

    assert_redirected_to oyster_invoice_url(OysterInvoice.last)
  end

  test "should show oyster_invoice" do
    get oyster_invoice_url(@oyster_invoice)
    assert_response :success
  end

  test "should get edit" do
    get edit_oyster_invoice_url(@oyster_invoice)
    assert_response :success
  end

  test "should update oyster_invoice" do
    patch oyster_invoice_url(@oyster_invoice), params: { oyster_invoice: { aioi_all_pdf: @oyster_invoice.aioi_all_pdf, aioi_seperated_pdf: @oyster_invoice.aioi_seperated_pdf, completed: @oyster_invoice.completed, data: @oyster_invoice.data, emails: @oyster_invoice.emails, end_date: @oyster_invoice.end_date, sakoshi_all_pdf: @oyster_invoice.sakoshi_all_pdf, sakoshi_seperated_pdf: @oyster_invoice.sakoshi_seperated_pdf, start_date: @oyster_invoice.start_date } }
    assert_redirected_to oyster_invoice_url(@oyster_invoice)
  end

  test "should destroy oyster_invoice" do
    assert_difference('OysterInvoice.count', -1) do
      delete oyster_invoice_url(@oyster_invoice)
    end

    assert_redirected_to oyster_invoices_url
  end
end
