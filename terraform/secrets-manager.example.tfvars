managed_secrets = {
  empty_shell = {
    description = "Creates the secret metadata only. Populate the value manually after apply."
    mode        = "empty"
  }

  generated_database_admin = {
    description = "Creates a JSON secret with a generated password for a database admin user."
    mode        = "generated"
    secret_name = "hello-world-app"
    secret_string_template = {
      username = "dbadmin"
      engine   = "postgres"
    }
  }
}

existing_secret_names = [
  "hello-world-app-rds-credentials"
]

example_rds_secret_name = "hello-world-app-rds-credentials"
