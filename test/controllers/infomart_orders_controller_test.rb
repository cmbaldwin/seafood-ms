require 'test_helper'

class InfomartOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @infomart_order = infomart_orders(:one)
  end

  test "should get index" do
    get infomart_orders_url
    assert_response :success
  end

  test "should get new" do
    get new_infomart_order_url
    assert_response :success
  end

  test "should create infomart_order" do
    assert_difference('InfomartOrder.count') do
      post infomart_orders_url, params: { infomart_order: { address: @infomart_order.address, arrival_date: @infomart_order.arrival_date, csv_data: @infomart_order.csv_data, items: @infomart_order.items, order_date: @infomart_order.order_date, order_id: @infomart_order.order_id, ship_date: @infomart_order.ship_date } }
    end

    assert_redirected_to infomart_order_url(InfomartOrder.last)
  end

  test "should show infomart_order" do
    get infomart_order_url(@infomart_order)
    assert_response :success
  end

  test "should get edit" do
    get edit_infomart_order_url(@infomart_order)
    assert_response :success
  end

  test "should update infomart_order" do
    patch infomart_order_url(@infomart_order), params: { infomart_order: { address: @infomart_order.address, arrival_date: @infomart_order.arrival_date, csv_data: @infomart_order.csv_data, items: @infomart_order.items, order_date: @infomart_order.order_date, order_id: @infomart_order.order_id, ship_date: @infomart_order.ship_date } }
    assert_redirected_to infomart_order_url(@infomart_order)
  end

  test "should destroy infomart_order" do
    assert_difference('InfomartOrder.count', -1) do
      delete infomart_order_url(@infomart_order)
    end

    assert_redirected_to infomart_orders_url
  end
end
