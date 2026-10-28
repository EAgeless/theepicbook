# EpicBook Application Deployment

Assignment 04 application automation using Ansible and Azure DevOps.

## Role responsibilities

- common: required packages, users, and permissions.
- frontend: Nginx reverse proxy to the backend private IP.
- backend: EpicBook deployment and persistent application service.
- database: private MySQL connectivity, schema, and seed initialization.
- verification: service, HTTP, and database checks.

## Infrastructure handoff

Only approved non-sensitive Terraform outputs belong in inventory
and committed variable files.

## Secrets

- SSH private key: Azure DevOps Secure Files.
- Database password: Azure DevOps secret variable or secured variable group.
- Never commit credentials or private keys.
