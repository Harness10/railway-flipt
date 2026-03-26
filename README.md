# Flipt on Railway: Harness10

An extended Flipt Dockerfile for running Flipt v2 in Railway local-first (Git-native) on a persistent volume, configured for the Harness10 organization with GitHub OAuth authentication.

This is a fork of the [vehm/railway-flipt](https://github.com/vehm/railway-flipt) template, hardened for internal use at Harness10.

## What this is

[Flipt](https://flipt.io) is an open-source feature flag and A/B testing platform. This repo extends the official Flipt v2 image to work cleanly on Railway with a persistent volume for local (Git-native) storage. It does not provision infrastructure on its own. The persistent volume must be added in Railway after deploying the service. Once mounted at `/var/opt/flipt`, Flipt will use it for all local storage (flags, segments, rules, etc.).

### Volume permissions

Railway mounts persistent volumes as root, but the Flipt process runs as the `flipt` user. Without intervention, Flipt would fail to write to the volume on first start. To handle this, the Dockerfile installs `sudo` and adds a scoped `sudoers` entry that allows the `flipt` user to run `/bin/chown` as root, and only that command. The entrypoint runs `chown -R flipt:flipt /var/opt/flipt` before handing off to the Flipt server, which corrects ownership of the entire volume mount at startup. This means the container starts cleanly regardless of how Railway initially owns the mount point.

## Configuration

The base configuration lives in `config.yml` and is copied into the image at build time. It sets the storage backend to `local` at `/var/opt/flipt` and enables GitHub OAuth authentication scoped to the Harness10 organization.

You can override any Flipt configuration option using environment variables. Flipt maps environment variables to config keys using the `FLIPT_` prefix with underscores replacing dots. See the [environment variables](https://docs.flipt.io/v2/configuration/overview#environment-variables-2) section of the Flipt configuration docs for more information.

## Authentication

**This deployment requires GitHub OAuth membership in the Harness10 organization.** The Flipt UI and API are protected: only GitHub users who are members of the [Harness10](https://github.com/Harness10) organization can authenticate.

The evaluation API is excluded from authentication so that services consuming feature flags can reach it without credentials.

### How it works

Authentication is configured in `config.yml` using Flipt's built-in GitHub OAuth method:

- `allowed_organizations: [Harness10]` - only Harness10 org members can log in
- `scopes: [read:org]` - requests the minimum GitHub scope needed to verify org membership
- Session cookies are secured with HTTPS and CSRF protection

### Required environment variables

Set these in your Railway service before deploying:

| Variable | Description |
|---|---|
| `GITHUB_CLIENT_ID` | OAuth App client ID from GitHub |
| `GITHUB_CLIENT_SECRET` | OAuth App client secret from GitHub |
| `GITHUB_REDIRECT_ADDRESS` | Full callback URL, e.g. `https://your-service.up.railway.app` |
| `CSRF_KEY` | Random secret used to sign CSRF tokens. Generate with `openssl rand -base64 64` |
| `RAILWAY_PUBLIC_DOMAIN` | Set automatically by Railway |

### GitHub OAuth App setup

1. Go to your GitHub organization settings → Developer settings → OAuth Apps → New OAuth App.
2. Set the **Authorization callback URL** to your Railway application URL, e.g. `https://<your-railway-domain>.up.railway.app`.
3. Copy the Client ID and generate a Client Secret, then add them as environment variables in Railway.
