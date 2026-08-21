# frozen_string_literal: true

# ⚠️  DELIBERATELY VULNERABLE — TEST FIXTURE, DO NOT USE  ⚠️
#
# Synthetic code written to exercise the Conviso AST pipeline (issue #14290).
# Every method below contains a known vulnerability on purpose, so the scanner
# has something to report for this branch. Nothing here is called by the app.
# Delete this file once the pipeline has been validated.

module ConvisoAstFixture
  # Branch: homolog — 2 findings expected
  class HomologSample
    # 1. Remote code execution: eval over untrusted input
    def calculate(expression)
      eval(expression)
    end

    # 2. Path traversal: unsanitised path reaches the filesystem
    def read_report(name)
      File.read("/var/reports/#{name}")
    end
  end
end
