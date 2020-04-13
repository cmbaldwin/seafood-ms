require 'test_helper'

class FrozenOystersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @frozen_oyster = frozen_oysters(:one)
  end

  test "should get index" do
    get frozen_oysters_url
    assert_response :success
  end

  test "should get new" do
    get new_frozen_oyster_url
    assert_response :success
  end

  test "should create frozen_oyster" do
    assert_difference('FrozenOyster.count') do
      post frozen_oysters_url, params: { frozen_oyster: { finished_packs: @frozen_oyster.finished_packs, frozen_l: @frozen_oyster.frozen_l, frozen_ll: @frozen_oyster.frozen_ll, hyogo_raw: @frozen_oyster.hyogo_raw, sakoshi_raw: @frozen_oyster.sakoshi_raw } }
    end

    assert_redirected_to frozen_oyster_url(FrozenOyster.last)
  end

  test "should show frozen_oyster" do
    get frozen_oyster_url(@frozen_oyster)
    assert_response :success
  end

  test "should get edit" do
    get edit_frozen_oyster_url(@frozen_oyster)
    assert_response :success
  end

  test "should update frozen_oyster" do
    patch frozen_oyster_url(@frozen_oyster), params: { frozen_oyster: { finished_packs: @frozen_oyster.finished_packs, frozen_l: @frozen_oyster.frozen_l, frozen_ll: @frozen_oyster.frozen_ll, hyogo_raw: @frozen_oyster.hyogo_raw, sakoshi_raw: @frozen_oyster.sakoshi_raw } }
    assert_redirected_to frozen_oyster_url(@frozen_oyster)
  end

  test "should destroy frozen_oyster" do
    assert_difference('FrozenOyster.count', -1) do
      delete frozen_oyster_url(@frozen_oyster)
    end

    assert_redirected_to frozen_oysters_url
  end
end
