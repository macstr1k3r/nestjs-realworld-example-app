## NestJS real world example app, extended with CI/CD, IaC and more.
----------
[Repository URL](https://github.com/macstr1k3r/nestjs-realworld-example-app).


Due to a time constraint of 4 hours, some of the modifications are up to a POC, rather than a production ready level.

The original example application has been adapted to use `PostgreSQL`

---
A docker compose file has been created to facilitate local development.
For local development `yarn docker` should provide a working local dev environment including hot reloading. As configured currently, The application will be available at `http://localhost:2000/`

---
Configuration management has intentionally been left out in favour of time.
A viable approach would be to inject the required configuration and secrets at runtime using `AWS Secrets Manager` or `AWS Parameter Store` as environment variables, and have a proper governance process around those.

The fact that the `.env` file contains some credentials is a non-issue since those are used only for running the local environment.

Variables prefixed with `NRW_` are by convention used by the application at runtime an should be provided respectively.

---- 
`CI/CD` is implemented using Github Actions. To learn more see `.github/workflows/README.md`

---
`AWS` has been chosen as the cloud provider to deploy the application to. То learn more see `terraform/README.md`

---
Stub `data importing` has been written at a **POC** level. Running `yarn import-data` will execute the correct code(`src/data-importer/`). The structure is such that existing database configuration and entity definitions are reused, ensuring correct entries however integration of the data importers into the local dev environment has been intentionally left out due to time constraints. If we were to seek to implement this, a small container that would execute `yarn import-data`, running before the app and after the database would be required.

---
`Performance testing` was de-scoped in favor of time. `k6` should be considered for a proper implementation.
