require 'redcarpet'

opts = {
  no_intra_emphasis: true,
  fenced_code_blocks: true,
  disable_indented_code_blocks: true,
  strikethrough: true,
  space_after_headers: true,
  superscript: true,
  highlight: true
}

smartHtml = Class.new(Redcarpet::Render::HTML) {
  include Redcarpet::Render::SmartyPants
}

Markdown = Redcarpet::Markdown.new(smartHtml, opts)
