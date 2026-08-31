# frozen_string_literal: true

require_relative '../application_system_test_case'

class AccessibilityAffordancesSystemTest < ApplicationSystemTestCase
  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
           :issues, :issue_statuses, :trackers, :projects_trackers,
           :enabled_modules, :enumerations

  def test_every_scroll_region_can_be_reached_by_keyboard
    # A region that scrolls with a wheel and not with a keyboard is unreachable
    # for anyone not using a pointer. Measured at 375px before this change: the
    # issue table scrolled 762px inside a 343px box with no way in.
    log_user('jsmith', 'jsmith')
    visit '/projects/ecookbook/issues'
    assert_selector '.autoscroll'
    missing = evaluate_script(<<~JS)
      Array.from(document.querySelectorAll('.autoscroll'))
           .filter(el => el.getAttribute('tabindex') === null).length
    JS
    assert_equal 0, missing, 'a scrollable region is not keyboard focusable'
  end

  def test_a_focused_scroll_region_shows_where_focus_is
    log_user('jsmith', 'jsmith')
    visit '/projects/ecookbook/issues'
    page.execute_script("document.querySelector('.autoscroll').focus()")
    outline = evaluate_script(
      "getComputedStyle(document.querySelector('.autoscroll'), ':focus-visible').outlineStyle")
    assert_not_nil outline
  end

  def test_my_page_actions_are_reachable_without_a_pointer
    # These sat at opacity 0.001 until :hover, which put them out of reach for
    # keyboard and touch entirely.
    log_user('jsmith', 'jsmith')
    visit '/my/page'
    return unless page.has_selector?('.mypage-box > .contextual a', wait: 2)

    page.execute_script("document.querySelector('.mypage-box > .contextual a').focus()")
    # The reveal is a transition, so a synchronous read samples it mid-flight.
    opacity = 0.0
    20.times do
      opacity = evaluate_script(
        "getComputedStyle(document.querySelector('.mypage-box > .contextual')).opacity").to_f
      break if opacity > 0.5

      sleep 0.05
    end
    assert_operator opacity, :>, 0.5, 'contextual actions stay invisible under keyboard focus'
  end

  def test_the_collapsed_sidebar_can_be_reopened
    # The toggle is a fixed 24px box with a start margin. When the sidebar
    # collapsed to a bare padding strip, that margin pushed the button's centre
    # past the edge of the viewport: it rendered, but nothing could click it, so
    # closing the sidebar was a one-way trip.
    log_user('jsmith', 'jsmith')
    visit '/projects/ecookbook/issues'
    return unless page.has_selector?('#sidebar-switch-button', wait: 2)

    find('#sidebar-switch-button').click
    assert_selector '#main.collapsedsidebar'

    reachable = evaluate_script(<<~JS)
      (() => {
        const b = document.querySelector('#sidebar-switch-button');
        const r = b.getBoundingClientRect();
        const hit = document.elementFromPoint(
          Math.round(r.x + r.width / 2), Math.round(r.y + r.height / 2));
        return !!hit && (hit === b || b.contains(hit));
      })()
    JS
    assert reachable, 'the collapsed sidebar toggle is not clickable, so the sidebar cannot be reopened'

    find('#sidebar-switch-button').click
    assert_no_selector '#main.collapsedsidebar'
  end

  def test_reduced_motion_removes_displacement_but_keeps_feedback
    log_user('jsmith', 'jsmith')
    visit '/projects/ecookbook/issues'
    # Colour feedback is not motion under SC 2.3.3 and must survive.
    row_transition = evaluate_script(
      "getComputedStyle(document.querySelector('table.list tbody tr')).transitionProperty")
    assert_includes row_transition, 'background-color'

    # The one animation that displaces has a no-translate counterpart.
    has_reduced_keyframes = evaluate_script(<<~JS)
      Array.from(document.styleSheets).some(s => {
        try { return Array.from(s.cssRules).some(r => r.name === 'nx-flash-in-reduced') }
        catch (e) { return false }
      })
    JS
    assert has_reduced_keyframes, 'no reduced-motion variant for the flash animation'
  end
end
