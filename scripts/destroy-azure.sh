#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
app_dir="${repo_root}/terraform/app"
aks_dir="${repo_root}/terraform/aks"

for command in az terraform; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    printf 'Required command not found: %s\n' "${command}" >&2
    exit 1
  fi
done

if ! subscription_id="$(az account show --query id --output tsv)"; then
  printf 'Azure CLI is not logged in. Run `az login` first.\n' >&2
  exit 1
fi

subscription_name="$(az account show --query name --output tsv)"

if [[ -z "${subscription_id}" || -z "${subscription_name}" ]]; then
  printf 'Could not read the active Azure subscription from `az account show`.\n' >&2
  exit 1
fi

if [[ -n "${ARM_SUBSCRIPTION_ID:-}" && "${ARM_SUBSCRIPTION_ID}" != "${subscription_id}" ]]; then
  printf 'ARM_SUBSCRIPTION_ID does not match the active Azure CLI subscription.\n' >&2
  exit 1
fi

printf 'Active Azure subscription: %s (%s)\n' "${subscription_name}" "${subscription_id}"

for terraform_dir in "${app_dir}" "${aks_dir}"; do
  terraform -chdir="${terraform_dir}" init -input=false
  state="$(terraform -chdir="${terraform_dir}" state list)"

  if [[ -z "${state}" ]]; then
    printf 'No Terraform resources found in state at %s; refusing to continue.\n' "${terraform_dir}" >&2
    exit 1
  fi

  if [[ "${terraform_dir}" == "${app_dir}" ]] && ! grep -q 'helm_release.argocd' <<< "${state}"; then
    printf 'Expected Argo CD Helm release is missing from state at %s.\n' "${terraform_dir}" >&2
    exit 1
  fi

  if [[ "${terraform_dir}" == "${aks_dir}" ]] && ! grep -Eq 'azurerm_kubernetes_cluster\.(production|dev)' <<< "${state}"; then
    printf 'Expected AKS cluster is missing from state at %s.\n' "${terraform_dir}" >&2
    exit 1
  fi
done

printf '\nThis will destroy Argo CD first, then the AKS cluster and resource group.\n'
read -r -p 'Type DESTROY to continue: ' confirmation
if [[ "${confirmation}" != "DESTROY" ]]; then
  printf 'Cancelled. No resources were destroyed.\n'
  exit 0
fi

terraform -chdir="${app_dir}" destroy
terraform -chdir="${aks_dir}" destroy

printf 'Azure AKS deployment destroyed.\n'