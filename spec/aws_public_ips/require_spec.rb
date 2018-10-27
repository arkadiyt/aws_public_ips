# frozen_string_literal: true

describe 'File requires' do
  def traverse(dir)
    results = {}

    ::Dir["#{dir}/*"].each do |path|
      next unless ::File.directory?(path)
      next unless ::File.exist?("#{path}.rb")

      results[path] = ::Dir["#{path}/*.rb"].map { |file| file.chomp('.rb') }
    end

    results
  end

  it 'should require all the right files' do
    stack = %w[lib]

    until stack.empty?
      matches = traverse(stack.pop)
      matches.each do |dir, files|
        stack.push(dir)
        expected_requires = files.sort.map do |file|
          "require '#{file.gsub(%r{^lib/}, '')}'"
        end.join("\n")
        expect(::IO.read("#{dir}.rb")).to include(expected_requires)
      end
    end
  end
end
