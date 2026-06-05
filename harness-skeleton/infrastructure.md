# 🏗️ infrastructure.md — Topología de la infra

> **Última actualización**: {{YYYY-MM-DD}}
> **Audiencia**: agentes de IA + futuros devs que hagan deploy/debug
> **Propósito**: mapa real de qué corre dónde — servidores, containers, red, volúmenes
> **Cuándo actualizar**: cuando se agrega/saca un servicio o se cambia de VPS

> 🚀 **Este doc aplica al path VPS (self-hosted comercial)**.
> Si vas con Vercel o local, no lo necesitás.

---

## VPS

| Campo | Valor |
|---|---|
| Provider | {{Contabo / Hetzner / DigitalOcean / Linode}} |
| Plan actual | {{Cloud VPS 10 / 20 / 30 — VDS M / L}} |
| Specs | {{vCPU / RAM / Disk / Bandwidth}} |
| Region | {{Nuremberg DE / USA Central / etc.}} |
| OS | Ubuntu 22.04 LTS |
| IP pública | {{xxx.xxx.xxx.xxx}} |
| SSH access | Solo via clave pública (no password) |

### Costo mensual
Ver [`costs.md`](costs.md) para el desglose completo.

---

## Red Docker

| Network | Tipo | Quién la usa |
|---|---|---|
| `{{network-name}}` | overlay (Swarm) | Todos los containers del proyecto |
| `traefik-public` | bridge | Solo Traefik (si está separado) |

---

## Containers en producción

| Servicio | Image | Puerto interno | Expose al exterior? | Notas |
|---|---|---|---|---|
| app | `{{PROJECT_NAME}}:latest` | 3000 | Via Traefik | Backend + frontend |
| postgres | `postgres:16` | 5432 | ❌ NO | Solo red Docker interna |
| redis | `redis:7-alpine` | 6379 | ❌ NO | Cache + queues |
| traefik | `traefik:v3.4` | 80/443 | ✅ Sí | Reverse proxy + auto-SSL |

### Servicios opcionales (descomentar en docker-stack.yml según se necesite)

| Servicio | Para qué | Cuándo activarlo |
|---|---|---|
| qdrant | Vector DB para RAG | Cuando agregás IA con búsqueda semántica |
| n8n | Workflow automation | Cuando querés integraciones sin codear |
| chatwoot | Inbox multicanal | Cuando necesitás soporte unificado |
| pgadmin | UI para Postgres | Solo desarrollo (no producción) |

---

## Volúmenes persistentes

| Volume | Container | Backup? | Tamaño actual | Crítico? |
|---|---|---|---|---|
| `postgres_data` | postgres | Diario a B2 | {{XX GB}} | 🚨 Sí — perderlo = perder DB |
| `uploads` | app | Diario a B2 | {{XX GB}} | 🚨 Sí — perder = uploads ido |
| `traefik_certs` | traefik | Manual | < 1 MB | 🟡 Medio (Let's Encrypt re-emite) |
| `redis_data` | redis | NO | < 100 MB | 🟢 No (es solo cache) |

---

## Dominios + DNS

| Dominio | Apunta a | Servicio | TLS |
|---|---|---|---|
| `{{tu-dominio.com}}` | Traefik :443 | app | Let's Encrypt auto-renew |
| `api.{{tu-dominio.com}}` | Traefik :443 | app `/api/*` | idem |

**Registrar dominios en**: {{Cloudflare / Namecheap / GoDaddy / etc.}}
**TTL recomendado**: 300s (5 min) para cambios rápidos en emergencias

---

## Variables de entorno

**Crítico**: las env vars NUNCA se commitean al repo. Vivienda:

| Donde | Para qué |
|---|---|
| `.env` local (gitignored) | Desarrollo |
| Docker Swarm secrets | Producción |
| Portainer UI (si lo usás) | Edit con audit log |

Ver [`.env.example`](../.env.example) para la lista completa de variables esperadas.

---

## Deploy pipeline

| Paso | Comando | Quién |
|---|---|---|
| 1. Build image local | `docker build -t {{PROJECT_NAME}}:latest .` | dev |
| 2. Push a registry | {{ghcr.io / Docker Hub / privado}} | dev |
| 3. SSH al VPS | `ssh root@{{IP}}` | dev |
| 4. Pull + deploy | `docker stack deploy -c docker-stack.yml {{stack}}` | dev |
| 5. Verificar health | `curl https://{{dominio}}/api/health` | dev |

Ver [`runbook.md`](runbook.md) sección "Deploy normal" para procedure paso a paso.

---

## Tiers de upgrade — cuándo cambiar de plan

Documentar **siempre que se hace upgrade** (NO upgradees por sentimiento):

| Métrica | Threshold | Cómo medirlo |
|---|---|---|
| RAM utilización sostenida | >70% por 7 días | `free -m` o Grafana |
| Disk utilización | >70% | `df -h` (alertar a 60%) |
| CPU load average | >2.5 sostenido | `uptime` |
| Postgres DB size | >50% del disk total | `\dt+` en psql |
| Latencia P95 endpoints | >500ms sostenido | UptimeRobot / Grafana |

### Plan actual: {{Cloud VPS 10}} ({{$5/mes}})
**Triggers para upgrade a {{Cloud VPS 20}}**:
- {{anotar acá cuando se cumpla la condición}}

### Próximo plan: {{Cloud VPS 30 — $15/mes}}
**Cuándo upgradear**:
- {{anotar el trigger específico que justificará el gasto extra}}

---

## Historial de cambios de infraestructura

| Fecha | Cambio | Por qué |
|---|---|---|
| {{YYYY-MM-DD}} | Setup inicial en {{plan}} | Arranque del proyecto |
| | | |

---

## Referencias

- [`disaster-recovery.md`](disaster-recovery.md) — qué hacer cuando se rompe
- [`monitoring.md`](monitoring.md) — cómo saber que está sano
- [`costs.md`](costs.md) — desglose de gastos mensuales
- [`runbook.md`](runbook.md) — procedimientos paso a paso
