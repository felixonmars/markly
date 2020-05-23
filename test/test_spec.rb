# frozen_string_literal: true

require 'test_helper'

class TestSpec < Minitest::Test
  spec = open_spec_file('spec.txt')

  spec.each do |testcase|
    next if testcase[:extensions].include?(:disabled)

    doc = Markly.parse(testcase[:markdown], extensions: testcase[:extensions])

    define_method("test_to_html_example_#{testcase[:example]}") do
      actual = doc.to_html(flags: Markly::UNSAFE, extensions: testcase[:extensions]).rstrip
      assert_equal testcase[:html], actual, testcase[:markdown]
    end

    define_method("test_html_renderer_example_#{testcase[:example]}") do
      actual = HtmlRenderer.new(flags: Markly::UNSAFE, extensions: testcase[:extensions]).render(doc).rstrip
      assert_equal testcase[:html], actual, testcase[:markdown]
    end

    define_method("test_source_position_example_#{testcase[:example]}") do
      lhs = doc.to_html(flags: Markly::UNSAFE|Markly::SOURCE_POSITION, extensions: testcase[:extensions]).rstrip
      rhs = HtmlRenderer.new(flags: Markly::UNSAFE|Markly::SOURCE_POSITION, extensions: testcase[:extensions]).render(doc).rstrip
      assert_equal lhs, rhs, testcase[:markdown]
    end
  end
end
