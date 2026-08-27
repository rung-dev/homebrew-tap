# rung: a verification-evidence framework with a deterministic, stdlib-only gate.
# rung has no runtime dependencies, so there are no resource blocks to vendor.
# Per release, bump url + sha256 to the new sdist. Copy the "Source Distribution"
# URL and its sha256 from the PyPI files page: https://pypi.org/project/rung-ai/#files
class Rung < Formula
  include Language::Python::Virtualenv

  desc "Deterministic gate that grades how real a verification was and who checked it"
  homepage "https://github.com/rung-dev/rung"
  url "https://files.pythonhosted.org/packages/c8/26/4095e24ac26e3f1a447bfafd4880a938f9a312fb51b93fe99d41506e215e/rung_ai-0.7.0.tar.gz"
  sha256 "b5886dd0266fda5bcf2e9e473507dd76f069a2dbb3e5278c794d359c91821853"
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
    # so write the capture and reference its real sha256. The bundle also carries every
    # schema-required field, so it validates against the published schema as well as
    # gating. brew test suppresses subprocess stdout, so the JSON verdict shows only
    # under `brew test --verbose`; the assert_match below is what enforces the pass.
    (testpath/"cap.txt").write "ok\n"
    require "digest"
    sha = Digest::SHA256.hexdigest(File.read(testpath/"cap.txt"))
    (testpath/"bundle.json").write <<~JSON
      {
        "schema": "evidence-bundle/v2",
        "change": {
          "repo": "homebrew formula smoke test",
          "s0": "n/a (single-run witness, no baseline)",
          "s1": "as-invoked: rung gate bundle.json",
          "producer": { "lab": "test-lab" }
        },
        "claims": [
          {
            "id": "c1",
            "claim": "Gated a minimal recorded observation",
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
