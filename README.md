# Flipt on Railway

An extended Flipt Dockerfile for running Flipt v2 in Railway local-first (Git-native) on a persistent volume.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/flipt-local?referralCode=_lCpBL&utm_medium=integration&utm_source=template&utm_campaign=generic)

## What this is

[Flipt](https://flipt.io) is an open-source feature flag and A/B testing platform. This repo extends the official Flipt v2 image to work cleanly on Railway with a persistent volume for local (Git-native) storage. It does not provision infrastructure on its own. The persistent volume must be added in Railway after deploying the service. Once mounted at `/var/opt/flipt`, Flipt will use it for all local storage (flags, segments, rules, etc.).

### Volume permissions

Railway mounts persistent volumes as root, but the Flipt process runs as the `flipt` user. Without intervention, Flipt would fail to write to the volume on first start. To handle this, the Dockerfile installs `sudo` and adds a scoped `sudoers` entry that allows the `flipt` user to run `/bin/chown` as root, and only that command. The entrypoint runs `chown -R flipt:flipt /var/opt/flipt` before handing off to the Flipt server, which corrects ownership of the entire volume mount at startup. This means the container starts cleanly regardless of how Railway initially owns the mount point.

## Configuration

The base configuration lives in `config.yml` and is copied into the image at build time. It sets the storage backend to `local` at `/var/opt/flipt`.

You can override any Flipt configuration option using environment variables. Flipt maps environment variables to config keys using the `FLIPT_` prefix with underscores replacing dots. See the [environment variables](https://docs.flipt.io/v2/configuration/overview#environment-variables-2) section of the Flipt configuration docs for more information.

## Authentication

**This template ships with no authentication configured.** If deployed as-is and exposed using a public domain, the Flipt UI and API are accessible to anyone who can reach the deployment URL.

You have a few options for securing your instance:

- **Fork and extend the config**: add an `authentication` block to `config.yml`. Flipt v2 supports static token, OIDC, GitHub, and other methods. See the [authentication docs](https://docs.flipt.io/v2/configuration/authentication).

- **Use environment variables**: configure authentication through Railway environment variables without modifying the image. For example, to enable static token authentication:

  ```
  FLIPT_AUTHENTICATION_REQUIRED=true
  FLIPT_AUTHENTICATION_METHODS_TOKEN_ENABLED=true
  FLIPT_AUTHENTICATION_METHODS_TOKEN_BOOTSTRAP_TOKEN=your-secret-token
  ```

  Refer to the [authentication docs](https://docs.flipt.io/v2/configuration/authentication) for the variable names corresponding to each method.

- **Network-level access control**: place the deployment behind a private tunnel so it is never publicly reachable. Tailscale (via sidecar or Tailscale Serve) and WireGuard are both good options. This should require no changes to the Flipt configuration and should work well when all consumers of the feature flag API are services within the same Railway project, and therefore on the same internal network.

