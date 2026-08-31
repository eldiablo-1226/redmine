# frozen_string_literal: true

require_relative '../application_system_test_case'

class AdminIndexGroupingSystemTest < ApplicationSystemTestCase
  fixtures :users, :email_addresses

  def teardown
    Redmine::MenuManager.map(:admin_menu) {|menu| menu.delete(:test_plugin_node)}
  rescue StandardError
    nil
  ensure
    super
  end

  def test_every_permitted_node_survives_grouping
    log_user('admin', 'admin')
    visit '/admin'
    expected = []
    Redmine::MenuManager.items(:admin_menu).root.children.each do |node|
      expected << node.name if node.allowed?(User.find(1), nil)
    end
    rendered = evaluate_script(
      "Array.from(document.querySelectorAll('#admin-menu a')).length")
    assert_operator rendered, :>=, expected.size,
                    'grouping dropped a node that the ungrouped menu would have rendered'
  end

  def test_core_info_node_is_named_rather_than_falling_through
    # :info is a core node. An early draft of the grouping omitted it, which would
    # have quietly filed a stock entry under the plugin catch-all.
    log_user('admin', 'admin')
    visit '/admin'
    other = find('.admin-menu-group', text: l(:label_admin_menu_other), match: :first) if
      page.has_selector?('.admin-menu-group', text: l(:label_admin_menu_other), wait: 0)
    assert_nil other, ':info fell into the Other group'
  end

  def test_a_plugin_injected_node_lands_in_other_rather_than_vanishing
    Redmine::MenuManager.map(:admin_menu) do |menu|
      menu.push(:test_plugin_node, {:controller => 'admin', :action => 'index'},
                :caption => 'Test plugin node')
    end
    log_user('admin', 'admin')
    visit '/admin'
    assert_selector '.admin-menu-group', text: l(:label_admin_menu_other)
    within('.admin-menu-group', text: l(:label_admin_menu_other)) do
      assert_text 'Test plugin node'
    end
  end

  def test_a_nested_child_menu_stays_a_list_and_does_not_become_a_grid
    log_user('admin', 'admin')
    visit '/admin'
    nested_grid = evaluate_script(<<~JS)
      Array.from(document.querySelectorAll('#admin-menu ul ul'))
           .filter(u => getComputedStyle(u).display === 'grid').length
    JS
    assert_equal 0, nested_grid
  end

  def test_the_shared_admin_sidebar_is_not_grouped
    # Grouping belongs to the directory page only; other admin screens keep the
    # plain sidebar list.
    log_user('admin', 'admin')
    visit '/admin/projects'
    assert_selector '#admin-menu'
    assert_no_selector '#admin-menu .admin-menu-group'
  end

  def test_admin_index_renders_under_a_third_locale
    # locales:update copies new keys into every locale with the English string,
    # so this asserts the real shipped state rather than a bare fallback.
    user = User.find(1)
    user.update_column(:language, 'de')
    log_user('admin', 'admin')
    visit '/admin'
    assert_selector '#admin-menu .admin-menu-group h3'
  end
end
