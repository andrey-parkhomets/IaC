# Atlantis

Atlantis currently runs inside a GitHub Actions job (`.github/workflows/atlantis.yml`):
each PR event or comment starts a server, relays the event to it, and stops it.

## What is portable

| Piece | Where | Hosted Atlantis (AKS / container) |
|---|---|---|
| Image (atlantis, az CLI, hcledit, `hcl-get`) | `docker/Dockerfile.debian` | same image |
| Server-side repo config, `azure` workflow | `.github/workflows/config/atlantis_repoConfig.yaml` | `--repo-config` / Helm `repoConfig` |
| Projects | `atlantis.yaml` | unchanged |
| Per-environment backend + subscription | `tf/<env>/backend.hcl` | unchanged |
| `ATLANTIS_*` settings | `env` of the job container | server env / Helm values |
| Azure auth | `ARM_USE_OIDC` + GitHub OIDC (`2ops_oidc`) | `ARM_USE_AKS_WORKLOAD_IDENTITY` (or `ARM_USE_MSI`) + `ARM_CLIENT_ID`/`ARM_TENANT_ID`; federated credential for the AKS service account |
| State access | `Storage Blob Data Contributor` on the state account | same role for the new identity (`state_contributor_principal_ids`) |

## GitHub Actions only

Dropped when moving to a hosted server:

- Event relay (`curl .../events`) in the `Run Atlantis` step. A hosted server gets a GitHub webhook (set a webhook secret) or a GitHub App instead.
- Data dir persistence: `atlantis-data` is stored as `atlantis/pr-<n>.tgz` in the state account, restored before and saved after each run, deleted once the PR is closed. A hosted server keeps it on a persistent volume and cleans up on its own.
- `azure/login` steps (only used by the blob restore/save).
- The `atlantis` container in `tf/bootstrap/<sub>` (`extra_containers`).

## Moving to a hosted server

1. Deploy the image (e.g. the official Helm chart) with a persistent volume for the data dir and the same `ATLANTIS_*` env and repo config.
2. Give the server identity a federated credential (AKS workload identity) and the Azure roles `2ops_oidc` has, plus state access via `state_contributor_principal_ids`.
3. Add the GitHub webhook (or GitHub App) pointing at the server.
4. Delete `.github/workflows/atlantis.yml` and the `atlantis` extra container.
