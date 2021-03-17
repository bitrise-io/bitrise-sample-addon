# Bitrise Sample Addon

This repo contains a sample Bitrise addon implementation. It's made for 3rd party developers who are about to develope a Bitrise addon.

What does an addon? A good example is the [Trace addon](https://www.bitrise.io/add-ons/trace-mobile-monitoring) and/or [Ship addon](https://blog.bitrise.io/deploy-with-bitrise-ship-open-beta).

## Project overview

An addon is basically a microservice with a fixed interface (endpoints)

- Language: Ruby
- Web framework: Rails

It was generated as a rails minimal API project without the ActiveRecords DB library.

## Mandatory endpoints

All endpoint must be idenpotent! A persistance layer is highly recommended because an addon need to store access tokens.

An addon must implement the following endpoints:

### Provisioning endpoint

`POST /provision`

### Deprovision endpoint

`DELETE /provision/:app_slug`

### Login (SSO) endpoint

`POST /login`

## Important files in the repo
