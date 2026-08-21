# frozen_string_literal: true

# ⚠️  DELIBERATELY VULNERABLE — TEST FIXTURE, DO NOT USE  ⚠️
#
# Synthetic code written to exercise the Conviso AST pipeline (issue #14290).
# Every method below contains a known vulnerability on purpose, so the scanner
# has something to report for this branch. Nothing here is called by the app.
# Delete this file once the pipeline has been validated.

module ConvisoAstFixture
  # Branch: master — 1 finding expected
  class MasterSample
    # 1. Mass assignment: every attribute the request carries is trusted
    def update_profile(user, params)
      user.update!(params)
    end
  end
end
