# Contributing

Issues and pull requests are welcome.

1. Open an issue describing the bug or proposed change.
2. Fork the repo and create a branch from `main`.
3. Run `terraform fmt -recursive`, `terraform validate` and `terraform test` in any module you change, and regenerate its docs with `terraform-docs --config .terraform-docs.yml modules/<name>` (or use `pre-commit`).
4. Open a pull request. CI must pass before review.

Keep modules small and single-purpose, give every variable a description, and document breaking changes in the PR.
