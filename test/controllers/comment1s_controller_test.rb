require 'test_helper'

class Comment1sControllerTest < ActionDispatch::IntegrationTest
  setup do
    @comment1 = comment1s(:one)
  end

  test "should get index" do
    get comment1s_url
    assert_response :success
  end

  test "should get new" do
    get new_comment1_url
    assert_response :success
  end

  test "should create comment1" do
    assert_difference('Comment1.count') do
      post comment1s_url, params: { comment1: { content: @comment1.content } }
    end

    assert_redirected_to comment1_url(Comment1.last)
  end

  test "should show comment1" do
    get comment1_url(@comment1)
    assert_response :success
  end

  test "should get edit" do
    get edit_comment1_url(@comment1)
    assert_response :success
  end

  test "should update comment1" do
    patch comment1_url(@comment1), params: { comment1: { content: @comment1.content } }
    assert_redirected_to comment1_url(@comment1)
  end

  test "should destroy comment1" do
    assert_difference('Comment1.count', -1) do
      delete comment1_url(@comment1)
    end

    assert_redirected_to comment1s_url
  end
end
