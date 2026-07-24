# Changelog

## [8.2.0](https://github.com/bgauduch/terraform-aws-cli/compare/v8.1.1...v8.2.0) (2026-07-24)


### Features

* **versions:** update Terraform (1.7–1.15) and AWS CLI to current releases ([#145](https://github.com/bgauduch/terraform-aws-cli/issues/145)) ([d4ff0c0](https://github.com/bgauduch/terraform-aws-cli/commit/d4ff0c0afe57a69c430cd72116421ad9651860d7))


### Bug Fixes

* **agent:** load binding docs into agent context at session start ([#146](https://github.com/bgauduch/terraform-aws-cli/issues/146)) ([1cadd7b](https://github.com/bgauduch/terraform-aws-cli/commit/1cadd7b25c5417f0029886fbe41b4578a571f900))
* **publish:** survive download failures and verify the release publication ([#149](https://github.com/bgauduch/terraform-aws-cli/issues/149)) ([1f2ac71](https://github.com/bgauduch/terraform-aws-cli/commit/1f2ac713b1a05e5c355314481aaffeea6860df42))

## [8.1.1](https://github.com/bgauduch/terraform-aws-cli/compare/v8.1.0...v8.1.1) (2026-07-23)


### Bug Fixes

* **publish:** point image identity to the bgauduch namespace ([#141](https://github.com/bgauduch/terraform-aws-cli/issues/141)) ([f251933](https://github.com/bgauduch/terraform-aws-cli/commit/f2519338ced5ca994b2105c0d1904d7d2aa4520a))

## [8.1.0](https://github.com/bgauduch/terraform-aws-cli/compare/v8.0.1...v8.1.0) (2026-07-22)


### Features

* **image:** migrate base image to Debian 13 (trixie) ([#133](https://github.com/bgauduch/terraform-aws-cli/issues/133)) ([3aebfdb](https://github.com/bgauduch/terraform-aws-cli/commit/3aebfdbf9155d6952a0a1a7e5dc10968d9c38f7a))

## [8.0.1](https://github.com/bgauduch/terraform-aws-cli/compare/v8.0.0...v8.0.1) (2026-07-19)


### Bug Fixes

* refresh apt package pins to current bookworm versions ([#124](https://github.com/bgauduch/terraform-aws-cli/issues/124)) ([cd5a5c6](https://github.com/bgauduch/terraform-aws-cli/commit/cd5a5c6aeea7648bbf05ceb5f6a8aa3035ae09ff))
