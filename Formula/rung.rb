# rung: a verification-evidence framework with a deterministic, stdlib-only gate.
# rung has no runtime dependencies, so there are no resource blocks to vendor.
# Per release, bump url + sha256 to the new sdist. Copy the "Source Distribution"
# URL and its sha256 from the PyPI files page: https://pypi.org/project/rung-ai/#files
class Rung < Formula
  include Language::Python::Virtualenv

  desc "Deterministic gate that grades how real a verification was and who checked it"
  homepage "https://github.com/rung-dev/rung"
  url "https://files.pythonhosted.org/packages/67/a2/368b0b48d33d0f05f38ebaa8f6654ba832c651f3284b585bb4dcce307c18/rung_ai-0.6.0.tar.gz"
  sha256 "771d9f760007a985f9be4b58859a6304fb235b8e5d86a812406c73fb0a15f81a"
  license "Apache-2.0"

  depends_on "python@3.13"

  def install
    virtualenv_install_with_resources
  end

  test do
    # version runs clean
    system bin/"rung", "version"
    # a minimal well-formed v2 bundle clears the default policy: verdict pass, exit 0.
    # rung 1 (observed) requires at least one capture artifact, which the gate hashes,
    # so write the capture and reference its real sha256. brew test suppresses
    # subprocess stdout, so the JSON verdict shows only under `brew test --verbose`;
    # the assert_match below is what enforces the pass.
    (testpath/"cap.txt").write "ok\n"
    require "digest"
    sha = Digest::SHA256.hexdigest(File.read(testpath/"cap.txt"))
    (testpath/"bundle.json").write <<~JSON
      {
        "schema": "evidence-bundle/v2",
        "change": { "producer": { "lab": "test-lab" } },
        "claims": [
          {
            "id": "c1",
            "risk_tier": "low",
            "rung": 1,
            "method": "single",
            "context": "author",
            "verdict": "pass",
            "artifacts": [
              { "id": "a0", "role": "capture", "media": "text/plain", "uri": "cap.txt", "sha256": "#{sha}" }
            ]
          }
        ]
      }
    JSON
    assert_match "\"verdict\": \"pass\"", shell_output("#{bin}/rung gate #{testpath}/bundle.json")
  end
end
