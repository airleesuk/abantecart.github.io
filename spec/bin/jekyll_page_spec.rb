require 'spec_helper'
require 'fileutils'
require 'date'

describe 'jekyll-page script' do
  let(:bin_path) { File.expand_path('../../bin/jekyll-page', __dir__) }
  let(:tmp_dir) { File.expand_path('../../tmp_test', __dir__) }
  let(:posts_dir) { File.join(tmp_dir, '_posts') }
  let(:pages_dir) { File.join(tmp_dir, '_pages') }

  before do
    FileUtils.rm_rf(tmp_dir)
    FileUtils.mkdir_p(posts_dir)
    # The script expects to be in bin/ sub-directory relative to project root by default
    # So if we run it from elsewhere, we need to pass -p path

    # We need to make the script executable
    File.chmod(0755, bin_path)
  end

  after do
    FileUtils.rm_rf(tmp_dir)
  end

  def run_script(args)
    # We use -p to point to our temp dir
    output = `ruby #{bin_path} -p #{tmp_dir} #{args} 2>&1`
    [$?, output]
  end

  it 'creates a new post with valid title and category' do
    status, output = run_script('"My New Post" "General"')
    expect(status.success?).to be true

    today = Date.today.strftime('%F')
    filename = "#{today}-my-new-post.md"
    filepath = File.join(posts_dir, filename)

    expect(File.exist?(filepath)).to be true
    content = File.read(filepath)
    expect(content).to include('title: "My New Post"')
    expect(content).to include('category: General')
    expect(content).to include("date: #{today}")
  end

  it 'creates a symlink in _pages' do
    status, output = run_script('"Linked Post" "General"')
    expect(status.success?).to be true

    filename = "linked-post.md"
    symlink = File.join(pages_dir, filename)

    expect(File.exist?(symlink)).to be true
    expect(File.symlink?(symlink)).to be true
    expect(File.readlink(symlink)).to include('_posts')
  end

  it 'fails if title or category is missing' do
    status, output = run_script('"Just Title"')
    # The script exits successfully but prints usage?
    # Actually checking the code:
    # if not title or not category ... puts parser; exit;
    # Exit code is 0 (success) by default in ruby exit.

    # But it should print usage.
    expect(output).to include('usage: jekyll-page')
  end

  it 'handles custom filenames' do
    status, output = run_script('"Custom File" "General" "custom-name"')
    expect(status.success?).to be true

    today = Date.today.strftime('%F')
    filepath = File.join(posts_dir, "#{today}-custom-name.md")
    expect(File.exist?(filepath)).to be true
  end

  it 'prevents overwriting existing files' do
    # Create file first
    run_script('"Duplicate" "General"')

    # Try again
    status, output = run_script('"Duplicate" "General"')
    # Code says: puts "File ... already exists"; exit
    expect(output).to include('already exists')
  end
end
