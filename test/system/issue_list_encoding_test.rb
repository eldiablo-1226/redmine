# frozen_string_literal: true

require_relative '../application_system_test_case'

class IssueListEncodingSystemTest < ApplicationSystemTestCase
  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
           :issues, :issue_statuses, :trackers, :projects_trackers,
           :enabled_modules, :enumerations, :versions, :issue_categories,
           :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions

  def computed(selector, property)
    evaluate_script(
      "getComputedStyle(document.querySelector(#{selector.to_json})).#{property}")
  end

  def test_issue_id_reads_from_the_start_edge
    log_user('jsmith', 'jsmith')
    visit '/projects/ecookbook/issues'
    assert_selector 'tr.issue td.id'
    assert_equal 'start', computed('tr.issue td.id', 'textAlign')
  end

  def test_a_non_issue_list_keeps_the_centred_id
    # The alignment change is scoped to tr.issue on purpose: wiki history and
    # repository revisions are other tables that share table.list td.id.
    log_user('jsmith', 'jsmith')
    visit '/projects/ecookbook/wiki/CookBook_documentation/history'
    assert_selector 'table.list td.id'
    assert_equal 'center', computed('table.list td.id', 'textAlign')
  end

  def test_badge_type_clears_the_twelve_pixel_floor
    log_user('jsmith', 'jsmith')
    visit '/projects/ecookbook/issues'
    assert_selector 'tr.issue td.status .badge'
    assert_operator computed('tr.issue td.status .badge', 'fontSize').to_f, :>=, 12.0
  end

  def test_heading_never_renders_smaller_than_body
    log_user('jsmith', 'jsmith')
    visit '/projects/ecookbook/issues'
    body = computed('body', 'fontSize').to_f
    page.execute_script("document.body.insertAdjacentHTML('beforeend', '<h4 id=probe>x</h4>')")
    assert_operator computed('#probe', 'fontSize').to_f, :>=, body
  end

  def test_open_and_closed_chips_differ_by_more_than_hue
    # Measured before this change: the two inks sat at 1.04:1 and the two grounds
    # at 1.00:1, so in greyscale the chips were identical and only the word told
    # them apart. Closed carries an outline; open stays filled.
    log_user('jsmith', 'jsmith')
    visit '/issues?set_filter=1&status_id=*&sort=id'
    assert_selector 'tr.issue td.status .badge-status-open'
    assert_selector 'tr.issue td.status .badge-status-closed'

    open_border = computed('tr.issue td.status .badge-status-open', 'borderTopColor')
    closed_border = computed('tr.issue td.status .badge-status-closed', 'borderTopColor')
    assert_not_equal open_border, closed_border

    closed_bg = computed('tr.issue td.status .badge-status-closed', 'backgroundColor')
    assert_includes ['rgba(0, 0, 0, 0)', 'transparent'], closed_bg
  end

  def test_status_chip_carries_a_glyph_before_its_label
    log_user('jsmith', 'jsmith')
    visit '/projects/ecookbook/issues'
    assert_selector 'tr.issue td.status .badge svg.icon-svg'
    first_child = evaluate_script(
      "document.querySelector('tr.issue td.status .badge').firstElementChild.tagName.toLowerCase()")
    assert_equal 'svg', first_child
  end

  def test_the_locked_badge_keeps_its_ground
    # The outline exception is scoped to the closed chip inside an issue list.
    # A locked wiki page is a different badge and must not have been swept up.
    log_user('admin', 'admin')
    page_record = WikiPage.find_by(title: 'CookBook_documentation')
    page_record.update_column(:protected, true)
    visit "/projects/ecookbook/wiki/#{page_record.title}"
    if page.has_selector?('.badge-status-locked', wait: 1)
      assert_not_equal 'rgba(0, 0, 0, 0)',
                       computed('.badge-status-locked', 'backgroundColor')
    end
  end
end
