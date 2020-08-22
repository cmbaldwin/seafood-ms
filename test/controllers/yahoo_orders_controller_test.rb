require 'test_helper'

class YahooOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @yahoo_order = yahoo_orders(:one)
  end

  test "should get index" do
    get yahoo_orders_url
    assert_response :success
  end

  test "should get new" do
    get new_yahoo_order_url
    assert_response :success
  end

  test "should create yahoo_order" do
    assert_difference('YahooOrder.count') do
      post yahoo_orders_url, params: { yahoo_order: { data: @yahoo_order.data, sales_date: @yahoo_order.sales_date } }
    end

    assert_redirected_to yahoo_order_url(YahooOrder.last)
  end

  test "should show yahoo_order" do
    get yahoo_order_url(@yahoo_order)
    assert_response :success
  end

  test "should get edit" do
    get edit_yahoo_order_url(@yahoo_order)
    assert_response :success
  end

  test "should update yahoo_order" do
    patch yahoo_order_url(@yahoo_order), params: { yahoo_order: { data: @yahoo_order.data, sales_date: @yahoo_order.sales_date } }
    assert_redirected_to yahoo_order_url(@yahoo_order)
  end

  test "should destroy yahoo_order" do
    assert_difference('YahooOrder.count', -1) do
      delete yahoo_order_url(@yahoo_order)
    end

    assert_redirected_to yahoo_orders_url
  end
end
