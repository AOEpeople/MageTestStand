# CHANGELOG for MageTestStand

This file is used to list changes made in each version of MageTestStand.

## 2.1.6
- add Magento CE 1.9.2.4

## 2.1.5
- add Magento CE 1.9.2.3

## 2.1.4
- use `configure` command of [magedownload-cli](https://github.com/steverobbins/magedownload-cli/releases/tag/v1.3.0) to be future-proof

## 2.1.3
- only run phpcs if $PHPCS is present

## 2.1.2
- conditionally use phpunit 4 or phpunit 5 dependent on php version used
- run setup scripts properly
- use our own [ECG Magento Code Sniffer Coding Standard](https://github.com/ffuenf/coding-standard) fork

## 2.1.1 
- use [ECG Magento Code Sniffer Coding Standard](https://github.com/magento-ecg/coding-standard)

## 2.1.0
- allow extension dependencies via composer
- revert additional services (use minimal setup)

## 2.0.0
- integrate chef
- integrate magedownload-cli
- integrate n98magerun modules
- add n98magerun module tests

## 1.0.2
- properly escape mysql db names
- switch to new n98-magerun download location
- copy vendor directory from workspace if exists
- update README with hint to SKIP_CLEANUP

## 1.0.1
- integrate code-coverage via scrutinizer-ci
- integrate code-coverage via codeclimate

## 1.0.0
- adjusted MageTestStand toolset by ffuenf
