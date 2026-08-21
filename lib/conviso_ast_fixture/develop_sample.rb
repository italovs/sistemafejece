# frozen_string_literal: true

# ⚠️  DELIBERATELY VULNERABLE — TEST FIXTURE, DO NOT USE  ⚠️
#
# Synthetic code written to exercise the Conviso AST pipeline (issue #14290).
# Every method below contains a known vulnerability on purpose, so the scanner
# has something to report for this branch. Nothing here is called by the app.
# Delete this file once the pipeline has been validated.

module ConvisoAstFixture
  # Branch: develop — 3 findings expected
  class DevelopSample
    # 1. SQL injection: user input interpolated straight into the query
    def find_user(conn, login)
      conn.execute("SELECT * FROM users WHERE login = '#{login}'")
    end

    # 2. Command injection: user input reaches the shell
    def ping(host)
      `ping -c 1 #{host}`
    end

    # 3. Hardcoded credential
    DB_PASSWORD = "fejece-admin-2019"

    def connect(client)
      client.login(user: "admin", password: DB_PASSWORD)
    end
  end
end
