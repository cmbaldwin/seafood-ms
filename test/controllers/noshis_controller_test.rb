require 'test_helper'

class NoshisControllerTest < ActionDispatch::IntegrationTest
  setup do
    @noshi = noshis(:one)
  end

  test "should get index" do
    get noshis_url
    assert_response :success
  end

  test "should get new" do
    get new_noshi_url
    assert_response :success
  end

  test "should create noshi" do
    assert_difference('Noshi.count') do
      post noshis_url, params: { noshi: { namae: @noshi.namae, ntype: @noshi.ntype, omotegaki: @noshi.omotegaki } }
    end

    assert_redirected_to noshi_url(Noshi.last)
  end

  test "should show noshi" do
    get noshi_url(@noshi)
    assert_response :success
  end

  test "should get edit" do
    get edit_noshi_url(@noshi)
    assert_response :success
  end

  test "should update noshi" do
    patch noshi_url(@noshi), params: { noshi: { namae: @noshi.namae, ntype: @noshi.ntype, omotegaki: @noshi.omotegaki } }
    assert_redirected_to noshi_url(@noshi)
  end

  test "should destroy noshi" do
    assert_difference('Noshi.count', -1) do
      delete noshi_url(@noshi)
    end

    assert_redirected_to noshis_url
  end
end
