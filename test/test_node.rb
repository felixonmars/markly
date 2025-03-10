# frozen_string_literal: true

require 'test_helper'

class TestNode < Minitest::Test
  def setup
    @doc = Markly.parse('Hi *there*, I am mostly text!')
  end

  def test_walk
    nodes = []
    @doc.walk do |node|
      nodes << node.type
    end
    assert_equal %i[document paragraph text emph text text], nodes
  end

  def test_each
    nodes = []
    @doc.first_child.each do |node|
      nodes << node.type
    end
    assert_equal %i[text emph text], nodes
  end

  def test_deprecated_each_child
    nodes = []
    _, err = capture_io do
      @doc.first_child.each_child do |node|
        nodes << node.type
      end
    end
    assert_equal %i[text emph text], nodes
    assert_match(/`each_child` is deprecated/, err)
  end

  def test_select
    nodes = @doc.first_child.select { |node| node.type == :text }
    assert_equal Markly::Node, nodes.first.class
    assert_equal %i[text text], nodes.map(&:type)
  end

  def test_map
    nodes = @doc.first_child.map(&:type)
    assert_equal %i[text emph text], nodes
  end

  def test_insert_illegal
    assert_raises Error do
      @doc.insert_before(@doc)
    end
  end

  def test_to_html
    assert_equal "<p>Hi <em>there</em>, I am mostly text!</p>\n", @doc.to_html
  end

  def test_html_renderer
    renderer = Renderer::HTML.new
    result = renderer.render(@doc)
    assert_equal "<p>Hi <em>there</em>, I am mostly text!</p>\n", result
  end

  def test_walk_and_set_string_content
    @doc.walk do |node|
      node.string_content = 'world' if node.type == :text && node.string_content == 'there'
    end
    result = Renderer::HTML.new.render(@doc)
    assert_equal "<p>Hi <em>world</em>, I am mostly text!</p>\n", result
  end

  def test_walk_and_delete_node
    @doc.walk do |node|
      if node.type == :emph
        node.insert_before(node.first_child)
        node.delete
      end
    end
    assert_equal "<p>Hi there, I am mostly text!</p>\n", @doc.to_html
  end

  def test_inspect
    assert_match(/#<Markly::Node\(document\):/, @doc.inspect)
  end

  def test_pretty_print
    assert_match(/#<Markly::Node\(document\):/, PP.pp(@doc, +''))
  end
end
