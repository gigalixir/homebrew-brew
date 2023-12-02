$now = Time.now.to_i

verbose(false)

desc 'Update gigalixir-cli formula'
task :default do
  venv_dir = File.join(Dir.pwd,"venv.#{$now}")

  # create virtualenv
  sh "virtualenv #{venv_dir}"

  # set the path to use virtualenv
  path_was = ENV['PATH']
  ENV['PATH'] = "#{venv_dir}/bin:#{ENV['PATH']}"

  # install gigalixir-cli and poet
  sh "pip install gigalixir homebrew-pypi-poet"

  # gather version of gigalixir-cli
  version = `gigalixir version`.strip
  puts "Installed version #{version}"

  # get package sha256
  pkg_url = "https://github.com/gigalixir/gigalixir-cli/archive/v#{version}.tar.gz"
  sh "wget #{pkg_url}"
  sha256 = `shasum -a 256 v#{version}.tar.gz`.split(' ')[0]
  sh "rm v#{version}.tar.gz"

  # generate formula resources
  poet = `poet gigalixir`
  ENV['PATH'] = path_was

  # remove gigalixir resource
  resources = []
  gigalixir = false
  poet.each_line do |line|
    if line =~ /resource "gigalixir"/
      gigalixir = true
    elsif line =~ /resource "/
      gigalixir = false
    end
    resources << line unless gigalixir
  end

  # write formula
  File.open('Formula/gigalixir.rb', 'w') do |f|
    f.puts <<-EOS
class Gigalixir < Formula
  include Language::Python::Virtualenv
  desc "Gigalixir CLI"
  homepage "https://www.gigalixir.com"
  url "https://github.com/gigalixir/gigalixir-cli/archive/v#{version}.tar.gz"
  sha256 "#{sha256}"

  depends_on "python"
  depends_on "rust" # needed for cryptography

#{resources.join}

  test do
    system bin/"gigalixir", "version"
  end

  def install
    virtualenv_install_with_resources
  end
end
EOS
  end
ensure
  # remove virtualenv
  sh "rm -rf #{venv_dir}"
end
