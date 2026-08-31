# frozen_string_literal: true

# Redmine - project management software
# Copyright (C) 2006-  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

module AdminHelper
  # Fourteen peers in one column asks the reader to know the menu already.
  # Grouping reorders across groups by construction; order inside a group is the
  # order the menu resolved to. A node that is not listed here — anything a
  # plugin pushed — lands in the trailing group rather than being dropped.
  ADMIN_MENU_GROUPS = [
    [:label_user_plural, [:users, :groups, :roles]],
    [:label_issue_plural, [:trackers, :issue_statuses, :workflows, :custom_fields, :enumerations]],
    [:label_administration, [:settings, :ldap_authentication, :applications, :plugins, :info]],
    [:label_project_plural, [:projects]]
  ].freeze

  def render_grouped_admin_menu
    nodes = []
    menu_items_for(:admin_menu) {|node| nodes << node}
    known = ADMIN_MENU_GROUPS.flat_map(&:last)

    groups = ADMIN_MENU_GROUPS.map do |caption, names|
      [caption, nodes.select {|node| names.include?(node.name)}]
    end
    others = nodes.reject {|node| known.include?(node.name)}
    groups << [:label_admin_menu_other, others] if others.any?

    safe_join(
      groups.filter_map do |caption, items|
        next if items.empty?

        content_tag(
          'section',
          content_tag('h3', l(caption)) +
            content_tag('ul', safe_join(items.map {|node| render_menu_node(node)})),
          :class => 'admin-menu-group')
      end)
  end

  def project_status_options_for_select(selected)
    options_for_select([[l(:label_all), ''],
                        [l(:project_status_active), '1'],
                        [l(:project_status_closed), '5'],
                        [l(:project_status_archived), '9'],
                        [l(:project_status_scheduled_for_deletion), '10']], selected.to_s)
  end

  def plugin_data_for_updates(plugins)
    data = {"v" => Redmine::VERSION.to_s, "p" => {}}
    plugins.each do |plugin|
      data["p"].merge! plugin.id => {"v" => plugin.version, "n" => plugin.name, "a" => plugin.author}
    end
    data
  end
end
