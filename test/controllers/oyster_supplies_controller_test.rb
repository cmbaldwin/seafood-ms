require 'test_helper'

class OysterSuppliesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @oyster_supply = oyster_supplies(:one)
  end

  test "should get index" do
    get oyster_supplies_url
    assert_response :success
  end

  test "should get new" do
    get new_oyster_supply_url
    assert_response :success
  end

  test "should create oyster_supply" do
    assert_difference('OysterSupply.count') do
      post oyster_supplies_url, params: { oyster_supply: { oysters: @oyster_supply.oysters, supply_date: @oyster_supply.supply_date } }
    end

    assert_redirected_to oyster_supply_url(OysterSupply.last)
  end

  test "should show oyster_supply" do
    get oyster_supply_url(@oyster_supply)
    assert_response :success
  end

  test "should get edit" do
    get edit_oyster_supply_url(@oyster_supply)
    assert_response :success
  end

  test "should update oyster_supply" do
    patch oyster_supply_url(@oyster_supply), params: { oyster_supply: { oysters: @oyster_supply.oysters, supply_date: @oyster_supply.supply_date } }
    assert_redirected_to oyster_supply_url(@oyster_supply)
  end

  test "should destroy oyster_supply" do
    assert_difference('OysterSupply.count', -1) do
      delete oyster_supply_url(@oyster_supply)
    end

    assert_redirected_to oyster_supplies_url
  end
end
