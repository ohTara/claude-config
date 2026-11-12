# Indice dei Ricordi Persistenti

## 👤 Utente e Preferenze
- [Preferenze di Sviluppo](preferenze-sviluppo.md) — Stack Cloud Specialist: Windows host, Ubuntu/Debian lab, AWS/Azure/GCP CLI, Terraform, kubectl, Helm, Podman (primary rootless), Docker
- [Configurazione Homeserver](configurazione-homeserver.md) — ASUS Vivobook headless (≤2GB RAM): SSH hardened, UFW, fail2ban, Samba NAS, Jellyfin (Podman, 500M RAM), Minecraft PaperMC (Podman, 800M RAM), Terraform-ready
- [Guida Sistema e Troubleshooting](guida-sistema-e-troubleshooting.md) — Memoria persistente + diagnostica accesso Jellyfin (porta 8096, UFW, Podman logs, Samba share)

## 📚 Materie ITS — Cloud Specialist (`Desktop/Materie_ITS_nuovo/`)
Repository di studio per il percorso **ITS Cloud Specialist**. Contiene 27 moduli organizzati per materia:

**Cloud & Infrastructure**
- `Cloud_Specialist/gcp-demo-sage` — Demo GCP con backend Python (FastAPI, Pydantic, httpx, Jinja2)
- `Amazon Web Services (AWS)` — Laboratori e certificazioni AWS
- `Microsoft Azure` / `Microsoft_Azure` — Azure fundamentals, CLI, ARM/Bicep
- `Containers_ITS-ICT` — Docker, Podman, Kubernetes basics
- `Sistemi di Virtualizzazione` — Hypervisor, VM, containerizzazione
- `Linux_Server` — Administration, hardening, systemd, Podman rootless
- `Fondamenti_di_Reti` — Networking, VLAN, routing, firewall
- `Fondamenti_Version_Control` — Git, GitHub, workflows

**Development & API**
- `C#` — .NET fundamentals
- `Python` — Scripting, automation, FastAPI
- `RESTFul_API` — Design, OpenAPI, testing
- `Fondamenti_di_programmazione` — Algoritmi, strutture dati
- `Fondamenti_di_Base_Dati` — SQL, NoSQL, modeling
- `Data_Analytics_e_Visualization` — Pandas, dashboard, reporting

**Security & Compliance**
- `Sicurezza_informatica` — Hardening, vulnerability assessment, OWASP
- `Copyright_e_norme_giuridiche_del_mondo_digitale` — GDPR, licenze, compliance
- `Sicurezza_Sul_Lavoro` — Normative sicurezza fisica/logica

**Soft Skills & Altro**
- `Soft_Skill` — Comunicazione, teamwork, presentation
- `Inglese` — Technical English
- `Pari_Opportunità` — Diversity & inclusion
- `Borsa_di_studi` — Documentazione borse di studio
- `.github` / `.postman` / `postman` — CI/CD workflows, API collections

**Modulo Omnia System** (`modulo-omnia-system/`) — Vedi sezione Project Work sotto

## 🛡️ Project Work — Omnia System (`Desktop/Project-Work---Omnia-System-main/` + `Desktop/Materie_ITS_nuovo/modulo-omnia-system/`)
**Cloud Security & DevSecOps Lab** — "Costruisci, Attacca e Difendi una Web App" su Microsoft Azure

### Architettura (3 VM Ubuntu in VNet `10.0.0.0/16`, Subnet `10.0.1.0/24`)
| VM | IP | Ruolo | Servizi |
|---|---|---|---|
| `vm-target` | 10.0.1.10 | Target Web App | OWASP Juice Shop (Docker `:3000`) |
| `vm-waf` | 10.0.1.20 | Reverse Proxy & WAF | Nginx + ModSecurity + OWASP CRS (`:80`) |
| `vm-siem` | 10.0.1.30 | SIEM Centralizzato | Wazuh Single-Node (Manager/Indexer/Dashboard `:55000`/`:443`) |

**Flusso:** Internet → WAF (filtra/blocca) → Juice Shop → Logs → SIEM (Wazuh detection + custom rules)

### Stack Tecnologico
- **IaC:** Terraform (AzureRM provider ~>3.0) — RG, VNet, Subnet, NSG, 3 VM, NIC, Public IPs
- **Config Mgmt:** Ansible — 4 play: common (Docker), target (Juice Shop), waf (ModSecurity), siem (Wazuh Docker)
- **SAST:** Checkov — Scan Terraform + Ansible (CI/CD)
- **CI/CD:** GitHub Actions (`.github/workflows/devsecops.yml`) — lint, checkov, deploy
- **Container:** Docker (Ansible `community.docker` collection)

### File Chiave
- `terraform/main.tf` — Risorse Azure (RG, VNet, Subnet, NSG allow SSH/HTTP/HTTPS/3000/55000)
- `terraform/vms.tf` — 3 VM Ubuntu 22.04, NIC, Public IP, SSH key, user_data cloud-init
- `terraform/output.tf` — Output IP pubblici VM
- `ansible/site.yml` — Orchestrazione 4 ruoli
- `ansible/inventory.ini` — Gruppi target/waf/siem + SSH vars
- `ansible/roles/common/tasks/main.yml` — apt update, installa docker.io + docker-compose
- `ansible/roles/target/tasks/main.yml` — Container `bkimminich/juice-shop` porta 3000
- `ansible/roles/waf/tasks/main.yml` — Container `owasp/modsecurity-crs:nginx` + config `default.conf` (proxy_pass → 10.0.1.10:3000, ModSecurity on, error_page 403 JSON)
- `ansible/roles/waf/files/default.conf` — Nginx reverse proxy + ModSecurity CRS
- `ansible/roles/siem/tasks/main.yml` — Git clone `wazuh-docker` v4.7.2, copia `custom_rules.xml`, `docker-compose up -d`
- `ansible/roles/siem/files/custom_rules.xml` — Regole Wazuh: ID 100001 (SQLi da ModSecurity SID 31100, MITRE T1190), ID 100002 (exploit login Juice Shop `/rest/user/login`)
- `scripts/validate_network.sh` — Test connettività post-deploy

### Checkov Results (da `docs/results_cli.txt`)
- **Terraform:** 4 passed, 3 failed
  - ❌ CKV_AZURE_160: HTTP (port 80) non ristretto da Internet
  - ❌ CKV_AZURE_10: SSH non ristretto da Internet
  - ❌ CKV2_AZURE_31: Subnet senza NSG associato
- **Ansible:** 4 passed, 0 failed

### Deployment Rapido
```bash
# 1. Terraform
cd terraform && terraform init && terraform apply -auto-approve

# 2. Ansible (aggiorna inventory.ini con IP output)
cd ../ansible && ansible-playbook -i inventory.ini site.yml
```

### Note per Sviluppo Futuro
- NSG troppo permissivo (source `*`) — da ristringere a IP admin / bastion
- Subnet manca associazione NSG esplicita in `azurerm_subnet_network_security_group_association`
- Wazuh `custom_rules.xml` copiato ma serve reload/regeneration rules per attivazione
- Pipeline GitHub Actions in `.github/workflows/devsecops.yml` (lint, checkov, deploy manual)
- Repo GitHub: `ohTara/Project-Work---Omnia-System` (badge CI in README)