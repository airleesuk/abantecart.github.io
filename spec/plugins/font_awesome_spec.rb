require 'spec_helper'
require 'jekyll'
require 'liquid'
require_relative '../../_plugins/font_awesome'

describe Jekyll::FontAwesomeTag do
  let(:context) { Liquid::Context.new }

  def render_icon(markup)
    # The plugin trims the markup inside initialize using @markup.strip
    # But determine_arguments does input.match(/\A(\S+) ?(\S+)?\Z/)
    # \S matches [^ \t\r\n\f]
    tag = Jekyll::FontAwesomeTag.parse('icon', markup, Liquid::Tokenizer.new(''), Liquid::ParseContext.new)
    tag.render(context)
  end

  context "with valid arguments" do
    it "renders a simple icon" do
      output = render_icon('fa-camera-retro')
      expect(output).to eq('<i class="fa fa-camera-retro"></i>')
    end

    it "renders an icon with extra classes" do
      output = render_icon('fa-camera-retro fa-lg')
      expect(output).to eq('<i class="fa fa-camera-retro fa-lg"></i>')
    end

    it "renders an icon with multiple extra classes" do
      output = render_icon('fa-spinner fa-spin fa-fw')
      expect(output).to eq('<i class="fa fa-spinner fa-spin fa-fw"></i>')
    end

    it "handles extra spaces correctly" do
      output = render_icon('  fa-camera-retro   fa-lg  ')
      expect(output).to eq('<i class="fa fa-camera-retro fa-lg"></i>')
    end
  end

  context "with invalid arguments" do
    it "raises an argument error for empty input" do
      expect { render_icon('') }.to raise_error(ArgumentError)
    end
  end
end
