# frozen_string_literal: true

# ⚠️  DELIBERATELY VULNERABLE — TEST FIXTURE, DO NOT USE  ⚠️
#
# Synthetic code written to exercise the Conviso AST pipeline (issue #14290).
# Every method below contains a known vulnerability on purpose, so the scanner
# has something to report for this branch. Nothing here is called by the app.
# Delete this file once the pipeline has been validated.

module ConvisoAstFixture
  # Branch: release/1.0 — 4 findings expected
  class ReleaseSample
    # 1. Weak hash for password storage
    def digest(password)
      Digest::MD5.hexdigest(password)
    end

    # 2. Insecure deserialization of untrusted data
    def restore(blob)
      Marshal.load(blob)
    end

    # 3. TLS verification disabled
    def http_client(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http
    end

    # 4. Predictable token generation
    def reset_token
      rand(1_000_000).to_s
    end
  end
end
