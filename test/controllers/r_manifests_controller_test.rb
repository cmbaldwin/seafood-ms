require 'test_helper'

class RManifestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @r_manifest = r_manifests(:one)
  end

  test "should get index" do
    get r_manifests_url
    assert_response :success
  end

  test "should get new" do
    get new_r_manifest_url
    assert_response :success
  end

  test "should create r_manifest" do
    assert_difference('RManifest.count') do
      post r_manifests_url, params: { r_manifest: { orders_hash: @r_manifest.orders_hash } }
    end

    assert_redirected_to r_manifest_url(RManifest.last)
  end

  test "should show r_manifest" do
    get r_manifest_url(@r_manifest)
    assert_response :success
  end

  test "should get edit" do
    get edit_r_manifest_url(@r_manifest)
    assert_response :success
  end

  test "should update r_manifest" do
    patch r_manifest_url(@r_manifest), params: { r_manifest: { orders_hash: @r_manifest.orders_hash } }
    assert_redirected_to r_manifest_url(@r_manifest)
  end

  test "should destroy r_manifest" do
    assert_difference('RManifest.count', -1) do
      delete r_manifest_url(@r_manifest)
    end

    assert_redirected_to r_manifests_url
  end
end
