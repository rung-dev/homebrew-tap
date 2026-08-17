# rung: a verification-evidence framework with a deterministic, stdlib-only gate.
# rung has no runtime dependencies, so there are no resource blocks to vendor.
# Per release, bump url + sha256 to the new sdist. Copy the "Source Distribution"
# URL and its sha256 from the PyPI files page: https://pypi.org/project/rung-ai/#files
class Rung < Formula
  include Language::Python::Virtualenv

  desc "Deterministic gate that grades how real a verification was and who checked it"
  homepage "https://github.com/rung-dev/rung"
  url "https://files.pythonhosted.org/packages/b8/84/01e05cbbdf35fead9815119494dde9e593d71511a4a28601366b62d3bbf4/rung_ai-0.2.0.tar.gz"
  sha256 "e287d6b3778bc59d625f7ccbd29d5a615d7d23c56e9a5b8ce2fdd6624e28e25b"
  license "Apache-2.0"

  depends_on "python@3.13"

  def install
    virtualenv_install_with_resources
  end

  test do
    # version runs clean
    system bin/"rung", "version"
    # a minimal well-formed bundle clears the default policy: verdict pass, exit 0.
    # brew test suppresses subprocess stdout, so the JSON verdict shows only under
    # `brew test --verbose`; the assert_match below is what enforces the pass.
    (testpath/"bundle.json").write <<~JSON
      {
        "schema": "evidence-bundle/v1",
        "change": { "producer": { "lab": "test-lab" } },
        "claims": [
          { "id": "c1", "risk_tier": "low", "rung": 2, "context": "author", "verdict": "pass" }
        ]
      }
    JSON
    assert_match "\"verdict\": \"pass\"", shell_output("#{bin}/rung gate #{testpath}/bundle.json")
  end
end
