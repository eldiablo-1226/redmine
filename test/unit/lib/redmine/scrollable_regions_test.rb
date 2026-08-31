# frozen_string_literal: true

require_relative '../../../test_helper'

# A region that scrolls with a wheel and not with a keyboard hides its overflow
# from anyone not using a pointer. This is a structural check rather than a
# system test on purpose: there are 27 `.autoscroll` regions across the views and
# a browser test would only ever visit a handful of them. Two instances were
# missed on the first pass precisely because they were found by matching a
# literal string instead of the class.
class ScrollableRegionsTest < ActiveSupport::TestCase
  VIEWS = Rails.root.join('app', 'views')

  def test_every_autoscroll_region_is_keyboard_focusable
    offenders = []

    Dir.glob(VIEWS.join('**', '*.erb')).each do |path|
      File.readlines(path).each_with_index do |line, i|
        next unless line.match?(/class\s*=\s*["'][^"']*\bautoscroll\b/)
        next if line.include?('tabindex')

        offenders << "#{Pathname.new(path).relative_path_from(Rails.root)}:#{i + 1}"
      end
    end

    assert_empty offenders,
                 "scrollable regions that cannot be reached by keyboard:\n  #{offenders.join("\n  ")}"
  end
end
