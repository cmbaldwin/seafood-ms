require 'test_helper'

class OnlineOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @online_order = online_orders(:one)
  end

  test "should get index" do
    get online_orders_url
    assert_response :success
  end

  test "should get new" do
    get new_online_order_url
    assert_response :success
  end

  test "should create online_order" do
    assert_difference('OnlineOrder.count') do
      post online_orders_url, params: { online_order: { arrival_date: @online_order.arrival_date, data: @online_order.data, date_modified: @online_order.date_modified, order_date: @online_order.order_date, order_id: @online_order.order_id, ship_date: @online_order.ship_date, status: @online_order.status } }
    end

    assert_redirected_to online_order_url(OnlineOrder.last)
  end

  test "should show online_order" do
    get online_order_url(@online_order)
    assert_response :success
  end

  test "should get edit" do
    get edit_online_order_url(@online_order)
    assert_response :success
  end

  test "should update online_order" do
    patch online_order_url(@online_order), params: { online_order: { arrival_date: @online_order.arrival_date, data: @online_order.data, date_modified: @online_order.date_modified, order_date: @online_order.order_date, order_id: @online_order.order_id, ship_date: @online_order.ship_date, status: @online_order.status } }
    assert_redirected_to online_order_url(@online_order)
  end

  test "should destroy online_order" do
    assert_difference('OnlineOrder.count', -1) do
      delete online_order_url(@online_order)
    end

    assert_redirected_to online_orders_url
  end
end
