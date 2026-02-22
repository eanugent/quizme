require 'test_helper'

class Admin::DataUploadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @password = "secret123"
    ENV['QUIZME_ADMIN_PASSWORD'] = @password
  end

  test "should get new with authentication" do
    get new_admin_data_upload_url, headers: { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials('admin', @password) }
    assert_response :success
  end

  test "should fail without authentication" do
    get new_admin_data_upload_url
    assert_response :unauthorized
  end

  test "should upload csv and create data" do
    csv_content = "Id,Game Type,Question,Kahoot?,_Subject A,_Subject B\n1,TestType,What is A?,1,5,0\n"
    file = Tempfile.new(['test', '.csv'])
    file.write(csv_content)
    file.rewind

    assert_difference 'Question.count', 1 do
      assert_difference 'Subject.count', 2 do
        assert_difference 'Answer.count', 2 do
          post admin_data_uploads_url, params: { csv_file: fixture_file_upload(file.path, 'text/csv') },
               headers: { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials('admin', @password) }
        end
      end
    end

    assert_response :success
    assert_match "Data updated successfully!", response.body
    
    q = Question.find(1)
    assert_equal "What is A?", q.question
    assert_equal "TestType", q.game_type
  end
end
