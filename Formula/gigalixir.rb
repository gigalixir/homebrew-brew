class Gigalixir < Formula
  include Language::Python::Virtualenv
  desc "Gigalixir CLI"
  homepage "https://www.gigalixir.com"
  url "https://github.com/gigalixir/gigalixir-cli/archive/1.1.0.tar.gz"
  sha256 "8f97ac1239b817957840ff54ce67d76d9b1fdf5876dc60b33273a89cd93b153b"

  depends_on "python"

  # see NOTES.md for how to generate these resources
  # do *not* include gigalixir in this list!

  resource "click" do
    url "https://files.pythonhosted.org/packages/95/d9/c3336b6b5711c3ab9d1d3a80f1a3e2afeb9d8c02a7166462f6cc96570897/click-6.7.tar.gz"
    sha256 "f15516df478d5a56180fbf80e68f206010e6d160fc39fa508b65e035fd75130b"
  end

  resource "Pygments" do
    url "https://files.pythonhosted.org/packages/71/2a/2e4e77803a8bd6408a2903340ac498cb0a2181811af7c9ec92cb70b0308a/Pygments-2.2.0.tar.gz"
    sha256 "dbae1046def0efb574852fab9e90209b23f556367b5a320c0bcb871c77c3e8cc"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/16/09/37b69de7c924d318e51ece1c4ceb679bf93be9d05973bb30c35babd596e2/requests-2.13.0.tar.gz"
    sha256 "5722cd09762faa01276230270ff16af7acf7c5c45d623868d9ba116f15791ce8"
  end

  resource "rollbar" do
    url "https://files.pythonhosted.org/packages/2a/a3/a1b8fc3985b61947e3b5f8fed4de9a2dbe19be12a4c6085a3af4b5f69d5e/rollbar-0.13.18.tar.gz"
    sha256 "f834ea7ea13a8b52306eb091eb74c52ea00744936fb9fc83a2c54477a44461ed"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/6b/34/415834bfdafca3c5f451532e8a8d9ba89a21c9743a0c59fbd0205c7f9426/six-1.15.0.tar.gz"
    sha256 "30639c035cdb23534cd4aa2dd52c3bf48f06e5f4a941509c8bafd8ce11080259"
  end

  resource "stripe" do
    url "https://files.pythonhosted.org/packages/e3/67/5ab77380cec9874900f026ed21160e2e1a3b70b258c68740f700a8800025/stripe-1.51.0.tar.gz"
    sha256 "c9097e103a4c6c44fd019ee4e3fe70f529009bfc84764daf6e35a8f0fad91d21"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    system bin/"gigalixir", "version"
  end
end
