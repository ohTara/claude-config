---
name: ascii-to-mermaid-progress
description: Progress tracking for ASCII to Mermaid diagram conversion across Dispense_ITS vault
metadata:
  type: project
---

# ASCII → Mermaid Conversion Progress

**Started:** 2026-11-18  
**Goal:** Convert all ASCII diagrams in Dispense_ITS vault to Mermaid format  
**Total files with ASCII diagrams (initial):** ~142 files across 18 subjects

## ✅ COMPLETED Subjects/Modules

### Linux Server (14/14 modules complete)
| Module | File | Mermaid Diagrams | Status |
|--------|------|------------------|--------|
| 01 | Architettura e Installazione | 3 | ✅ |
| 02 | Gestione Fileystem e Storage | 4 | ✅ |
| 03 | Gestione Pacchetti e Repository | 3 | ✅ |
| 04 | Systemd e Gestione Servizi | 7 | ✅ |
| 05 | Utenti, Gruppi, Permessi, ACL | 9 | ✅ |
| 06 | Rete Configurazione e Servizi | 4 | ✅ |
| 07 | Servizi di Rete Avanzati | 7 | ✅ |
| 08 | Scripting Bash e Automazione | 1 | ✅ |
| 09 | Containerizzazione Podman Docker Kubernetes | 5 | ✅ |
| 10 | Monitoraggio e Logging | 3 | ✅ |
| 11 | Sicurezza e Hardening | 6 | ✅ |
| 12 | High Availability e Clustering | 5 | ✅ |
| 13 | Backup, Disaster Recovery e Business Continuity | 5 | ✅ |
| 14 | Troubleshooting e Performance Tuning | 3 | ✅ |
| 99 | Cheatsheet, Glossario, Comandi | 0 | ✅ (none) |

**Linux Server Total: 62 diagrams**

### Containers (6/14 modules complete)
| Module | File | Mermaid Diagrams | Status |
|--------|------|------------------|--------|
| 02 | Immagini e container Docker | 1 | ✅ |
| 05 | File system a livelli, volumi, bind mount e tmpfs | 1 | ✅ |
| 06 | Docker Swarm e reti overlay | 2 | ✅ |
| 08 | Kubernetes Core Pod Deployment Service | 4 | ✅ |
| 09 | ConfigMap Secret e Helm | 1 | ✅ |
| 10 | Service e Ingress | 1 | ✅ |
| 11 | StatefulSet Job CronJob DaemonSet | 2 | ✅ |
| 12 | Operatori e Custom Resources | 3 | ✅ |
| 13 | Sicurezza Container e Best Practice | 1 | ✅ |

**Containers Total: 16 diagrams**  
**Remaining: 01, 03, 04, 07, 14, 99**

### Python Programmazione (6/16 modules complete)
| Module | File | Mermaid Diagrams | Status |
|--------|------|------------------|--------|
| 01 | Introduzione a Python e Setup | 2 | ✅ |
| 07 | Gestione Eccezioni e Testing | 1 | ✅ |
| 09 | Programmazione Asincrona | 1 | ✅ |
| 12 | Sicurezza Applicativa | 2 | ✅ |
| 13 | Containerizzazione e Docker | 4 | ✅ |
| 15 | Monitoring, Logging, Observability | 1 | ✅ |

**Python Total: 11 diagrams**  
**Remaining: 02, 03, 04, 05, 06, 08, 10, 11, 14, 16, 99**

### Sicurezza Informatica (0/12 modules complete)
**High priority - 12 modules with many diagrams:**
- 01: Fondamenti Cybersecurity
- 02: Gestione Password Autenticazione
- 03: (missing?)
- ...
- 12: Cloud Security DevSecOps

### Other Subjects with ASCII diagrams (not started)
| Subject | Modules with ASCII |
|---------|-------------------|
| Sistemi_di_Virtualizzazione | 07, 10 |
| Fondamenti_di_Reti | 02, 03, 04, 05, 07, 09, 10 |
| Fondamenti_di_Base_Dati | 01-10, 99 |
| Fondamenti_di_Programmazione_C | 06, 08, 09, 10, 11, 12, 13, 14 |
| CSharp_Programmazione_Oggetti | 01-04, 08, 16 |
| IoT | 01-07 |
| Soft_Skill | 02, 03, 99 |
| Microsoft_365_Office | 01-09 |
| Microsoft_Azure | 13-23 |
| Amazon_Web_Services_AWS | 03, 04, 05 |
| Cloud_Specialist_GCP_Sage | 09, 11, 12 |
| Data_Analytics_e_Visualization | 05, 06, 99 |
| RESTful_API_Progettazione | 03, 10, 99 |
| Fondamenti_Version_Control | 01-07 |
| Inglese | 03 |
| Pari_Opportunità | (check) |
| Sicurezza_Sul_Lavoro | (check) |

## 📊 Summary Statistics
- **Subjects complete:** 2 (Linux Server, Containers partially)
- **Subjects in progress:** 1 (Python)
- **Subjects not started:** 15+
- **Total diagrams converted:** ~89
- **Estimated remaining:** ~200+ diagrams

## 🔧 Methodology Established
1. Use `extract_*.py` script to find ASCII blocks with box-drawing characters
2. Create `fix_*.py` script with exact string matching for replacement
3. Use `sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')` for Unicode handling
4. Verify with mermaid count and box-char count

## 📝 Next Steps
1. Complete Python modules 15, 16 (Monitoring, Architetture)
2. Complete remaining Containers modules
3. Tackle Sicurezza Informatica (high diagram count)
4. Process remaining subjects in priority order

## 💾 Files Created (in ~/Desktop/)
- `extract_*.py` - extraction scripts per module
- `fix_*.py` - conversion scripts per module
- `verify_*.py` - verification scripts

## How to Resume
```bash
# For any module:
python extract_<module>.py    # Find remaining ASCII diagrams
python fix_<module>.py        # Convert to Mermaid
python -c "import sys, io; sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace'); path = r'<path>'; content = open(path, encoding='utf-8').read(); print(f'Mermaid: {content.count(chr(96)*3 + \"mermaid\")}')"  # Verify
```

**Perché:** Traccia il progresso massivo di conversione per poter riprendere in future sessioni senza perdere contesto.  
**Come applicare:** Leggere questo file all'avvio; usare gli script extract/fix esistenti come template per nuovi moduli.