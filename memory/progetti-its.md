---
name: progetti-its
description: Progetti e repository del percorso ITS Cloud Specialist
metadata:
  type: project
---

## Omnia System — Project Work (`ohTara/Project-Work---Omnia-System`)
Laboratorio "Costruisci, Attacca e Difendi una Web App su Azure" per AizoOn / ITS Piemonte. Lavoro di gruppo (con Anis Ravera).
- Azure `westeurope`, RG `rg-lab-cloudsec-devsecops`, VNet `10.0.0.0/16`, subnet `10.0.1.0/24`.
- `vm-target` 10.0.1.10 (OWASP Juice Shop, :3000), `vm-waf` 10.0.1.20 (Nginx + ModSecurity + CRS, :80), `vm-siem` 10.0.1.30 (Wazuh single-node).
- Terraform per l'infrastruttura, Ansible (`site.yml`, ruoli `common`, `target`, `waf`, `siem`) per il software, Checkov e `terraform validate` in GitHub Actions.
- Fasi: IaC → Red Team (SQL injection sul login) → Blue Team (WAF + SIEM).

## Sage — RAG su Google Cloud (`Materie_ITS/Cloud_Specialist/gcp-demo-sage`)
FastAPI su Cloud Run; embedding e Gemini via Vertex AI; ricerca vettoriale in Firestore (768 dimensioni); log in BigQuery; Terraform in `devops/cloud/`; regione `europe-west6`; dipendenze con uv. Nessuna API key (ADC).

## Echoes of the Crypt (`Materie_ITS/Python/Gioco_Python`)
Dungeon crawler in Python con `pygame-ce`: entità, nemici, dungeon, interfaccia, salvataggi JSON e database SQLite; eseguibile con PyInstaller.

## Materie_ITS (`ohTara/Materie_ITS`)
Raccolta di tutte le materie. Una cartella per materia, sottocartelle per data; documentazione per lezione in `docs/<materia>/<AAAA-MM-GG>-<slug>.md`; `MEMORY.md` e `PROGRESS.md` nella radice per il percorso di studio. Omnia System è incluso come submodule `modulo-omnia-system`.

**Perché:** sono i progetti su cui arrivano più spesso le richieste.
**Come applicare:** leggere i file della repo prima di rispondere; le stime e i dettagli non verificabili vanno segnati come *da verificare*.
