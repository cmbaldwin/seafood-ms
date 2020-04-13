require 'test_helper'

class ExpirationCardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @expiration_card = expiration_cards(:one)
  end

  test "should get index" do
    get expiration_cards_url
    assert_response :success
  end

  test "should get new" do
    get new_expiration_card_url
    assert_response :success
  end

  test "should create expiration_card" do
    assert_difference('ExpirationCard.count') do
      post expiration_cards_url, params: { expiration_card: { consumption_restrictions: @expiration_card.consumption_restrictions, expiration_date: @expiration_card.expiration_date, ingredient_source: @expiration_card.ingredient_source, manufactuered_date: @expiration_card.manufactuered_date, manufacturer: @expiration_card.manufacturer, manufacturer_address: @expiration_card.manufacturer_address, product_name: @expiration_card.product_name } }
    end

    assert_redirected_to expiration_card_url(ExpirationCard.last)
  end

  test "should show expiration_card" do
    get expiration_card_url(@expiration_card)
    assert_response :success
  end

  test "should get edit" do
    get edit_expiration_card_url(@expiration_card)
    assert_response :success
  end

  test "should update expiration_card" do
    patch expiration_card_url(@expiration_card), params: { expiration_card: { consumption_restrictions: @expiration_card.consumption_restrictions, expiration_date: @expiration_card.expiration_date, ingredient_source: @expiration_card.ingredient_source, manufactuered_date: @expiration_card.manufactuered_date, manufacturer: @expiration_card.manufacturer, manufacturer_address: @expiration_card.manufacturer_address, product_name: @expiration_card.product_name } }
    assert_redirected_to expiration_card_url(@expiration_card)
  end

  test "should destroy expiration_card" do
    assert_difference('ExpirationCard.count', -1) do
      delete expiration_card_url(@expiration_card)
    end

    assert_redirected_to expiration_cards_url
  end
end
