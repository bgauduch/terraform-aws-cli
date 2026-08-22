# Changelog

## [10.0.2](https://github.com/bgauduch/terraform-aws-cli/compare/v10.0.1...v10.0.2) (2026-08-22)


### Bug Fixes

* **release:** assert published tag digests, not tag existence ([#172](https://github.com/bgauduch/terraform-aws-cli/issues/172)) ([7384efa](https://github.com/bgauduch/terraform-aws-cli/commit/7384efaa5764d8120b73b4486e0ff99872c2cd89))

## [10.0.1](https://github.com/bgauduch/terraform-aws-cli/compare/v10.0.0...v10.0.1) (2026-08-18)


### Bug Fixes

* **docker:** refresh the superseded jq and unzip apt pins ([#168](https://github.com/bgauduch/terraform-aws-cli/issues/168)) ([196e9c0](https://github.com/bgauduch/terraform-aws-cli/commit/196e9c0f20811b851178a781b7a85592d9510777))

## [10.0.0](https://github.com/bgauduch/terraform-aws-cli/compare/v9.0.0...v10.0.0) (2026-08-03)


### ⚠ BREAKING CHANGES

* **ci:** `linux/arm/v7` and `linux/386` are no longer published — remaining platforms are `linux/amd64` and `linux/arm64`. Existing tags keep their manifests. ([#164](https://github.com/bgauduch/terraform-aws-cli/issues/164))

### Features

* **ci:** publish only the platforms upstream supports ([#164](https://github.com/bgauduch/terraform-aws-cli/issues/164)) ([73e2af9](https://github.com/bgauduch/terraform-aws-cli/commit/73e2af9979cb2a02276f35091bdf3e9e5d180ca3))

## [9.0.0](https://github.com/bgauduch/terraform-aws-cli/compare/v8.2.0...v9.0.0) (2026-08-03)


### ⚠ BREAKING CHANGES

* **ci:** `latest` now moves only on release — use `edge` for the tip of `master`. ([#163](https://github.com/bgauduch/terraform-aws-cli/issues/163))
* **versions:** Terraform lines below 1.13 are no longer built — supported: 1.13, 1.14, 1.15. Existing tags stay pullable. ([#158](https://github.com/bgauduch/terraform-aws-cli/issues/158))

### Features

* **ci:** one publisher per tag, edge from master and latest from releases ([#163](https://github.com/bgauduch/terraform-aws-cli/issues/163)) ([c766a9a](https://github.com/bgauduch/terraform-aws-cli/commit/c766a9ad2669bdaa0fee2eca9e74c95b7b67a004))
* **ci:** single validation oracle shared by human, agent and CI ([#160](https://github.com/bgauduch/terraform-aws-cli/issues/160)) ([45a9f0c](https://github.com/bgauduch/terraform-aws-cli/commit/45a9f0c662d1d6ebef51f99b5dc4d3950a038021))
* **versions:** support follows upstream EOL, retire minors below 1.13 ([#158](https://github.com/bgauduch/terraform-aws-cli/issues/158)) ([7bcff8e](https://github.com/bgauduch/terraform-aws-cli/commit/7bcff8e753153abf67b11a48853bbfc1fd001163))


### Bug Fixes

* **docker:** install the arch-native aws cli bundle ([#162](https://github.com/bgauduch/terraform-aws-cli/issues/162)) ([a4d090b](https://github.com/bgauduch/terraform-aws-cli/commit/a4d090b11d9e0a24f19e6d91af38027388ac320d))

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
