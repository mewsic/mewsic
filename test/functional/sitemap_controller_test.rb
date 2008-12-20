require File.dirname(__FILE__) + '/../test_helper'

class SitemapControllerTest < ActionController::TestCase
  def test_should_render_sitemap
    get :index, :format => 'xml'

    assert_response :success
    assert_template 'index'
  end

  def test_should_fetch_correct_resources
    get :index, :format => 'xml'

    resources = assigns(:resources)

    assert resources
    assert_equal %w(songs users answers help genres mbands).sort, resources.keys.sort

    assert resources['songs'].all? { |s| s.published? }
    assert resources['users'].all? { |u| !u.activated_at.nil? }
    assert resources['genres'].all? { |g| g.song_count > 0 }
    assert resources['mbands'].all? { |m| m.members_count > 1 }
  end
end
