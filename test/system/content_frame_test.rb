# frozen_string_literal: true

require_relative '../application_system_test_case'

class ContentFrameSystemTest < ApplicationSystemTestCase
  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
           :issues, :issue_statuses, :trackers, :projects_trackers,
           :enabled_modules, :enumerations, :repositories

  FRAME = 1280

  def content_width
    evaluate_script("document.querySelector('#content').getBoundingClientRect().width")
  end

  def frame_token
    evaluate_script(
      "getComputedStyle(document.querySelector('#content')).maxInlineSize")
  end

  def widen(width = 2100)
    page.driver.browser.manage.window.resize_to(width, 1000)
  end

  def test_a_framed_action_bounds_its_content_column
    widen
    log_user('admin', 'admin')
    visit '/admin'
    assert_equal "#{FRAME}px", frame_token
    assert_operator content_width, :<=, FRAME + 1
  end

  def test_the_frame_is_the_outer_box_not_the_content_box
    # #content carries 28px of inline padding and the stylesheet has no universal
    # reset, so without an explicit border-box a 1280 frame renders 1336 wide.
    widen
    log_user('admin', 'admin')
    visit '/admin'
    assert_equal 'border-box',
                 evaluate_script("getComputedStyle(document.querySelector('#content')).boxSizing")
    assert_operator content_width, :<=, FRAME + 1
  end

  def test_an_issue_list_is_never_framed
    # Capping a dense table produces empty outer margins and a sideways scroll
    # inside them at the same time — the documented failure this avoids.
    widen
    log_user('jsmith', 'jsmith')
    visit '/projects/ecookbook/issues'
    assert_equal 'none', frame_token
    assert_operator content_width, :>, FRAME
  end

  def test_a_repository_view_is_never_framed
    widen
    log_user('jsmith', 'jsmith')
    visit '/projects/ecookbook/repository'
    assert_equal 'none', frame_token
  end

  def test_admin_subpages_with_wide_tables_are_not_framed
    widen
    log_user('admin', 'admin')
    visit '/admin/projects'
    assert_equal 'none', frame_token
  end

  def test_prose_measure_does_not_scale_with_heading_size
    # The measure was expressed in ch, which scales with the element's own
    # font-size and gave a 28px h1 a cap almost twice the width of the 14px prose
    # underneath it. In rem every block caps at the same width.
    widen
    log_user('jsmith', 'jsmith')
    visit '/projects/ecookbook/wiki'
    caps = evaluate_script(<<~JS)
      Array.from(document.querySelectorAll('.wiki > p, .wiki > h1, .wiki > h2'))
           .map(el => getComputedStyle(el).maxInlineSize)
    JS
    assert_operator caps.uniq.size, :<=, 1, "prose and headings cap at different widths: #{caps.uniq.inspect}"
  end
end
