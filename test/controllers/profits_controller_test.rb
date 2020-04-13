require 'test_helper'

class ProfitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @profit = profits(:one)
  end

  test "should get index" do
    get profits_url
    assert_response :success
  end

  test "should get new" do
    get new_profit_url
    assert_response :success
  end

  test "should create profit" do
    assert_difference('Profit.count') do
      post profits_url, params: { profit: {  } }
    end

    assert_redirected_to profit_url(Profit.last)
  end

  test "should show profit" do
    get profit_url(@profit)
    assert_response :success
  end

  test "should get edit" do
    get edit_profit_url(@profit)
    assert_response :success
  end

  test "should update profit" do
    patch profit_url(@profit), params: { profit: {  } }
    assert_redirected_to profit_url(@profit)
  end

  test "should destroy profit" do
    assert_difference('Profit.count', -1) do
      delete profit_url(@profit)
    end

    assert_redirected_to profits_url
  end
end
