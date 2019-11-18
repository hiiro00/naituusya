require "application_system_test_case"

class Comment1sTest < ApplicationSystemTestCase
  setup do
    @comment1 = comment1s(:one)
  end

  test "visiting the index" do
    visit comment1s_url
    assert_selector "h1", text: "Comment1s"
  end

  test "creating a Comment1" do
    visit comment1s_url
    click_on "New Comment1"

    fill_in "Content", with: @comment1.content
    click_on "Create Comment1"

    assert_text "Comment1 was successfully created"
    click_on "Back"
  end

  test "updating a Comment1" do
    visit comment1s_url
    click_on "Edit", match: :first

    fill_in "Content", with: @comment1.content
    click_on "Update Comment1"

    assert_text "Comment1 was successfully updated"
    click_on "Back"
  end

  test "destroying a Comment1" do
    visit comment1s_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Comment1 was successfully destroyed"
  end
end
