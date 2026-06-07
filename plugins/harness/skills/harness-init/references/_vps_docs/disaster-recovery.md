# 🚨 disaster-recovery.md — Cómo recuperarse de emergencias

> **Última actualización**: {{YYYY-MM-DD}}
> **Audiencia**: vos (o tu agente AI) a las 3am cuando algo se rompe
> **Propósito**: procedimientos exactos para restaurar el servicio
> **Cuándo actualizar**: cuando ocurre un incidente o se agrega un escenario

> 🚀 **Este doc aplica al path VPS (self-hosted comercial)**.
> Si vas con Vercel o local, los backups son más simples (Vercel maneja, local = `git push`).

---

## 💾 Estrategia de Backups

### Backup automatizado de la DB

| Campo | Valor |
|---|---|
| Frecuencia | Diaria a las 03:00 UTC owner TZ |
| Comando | `pg_dump` → comprimido a `/backups/db-YYYY-MM-DD.sql.gz` |
| Cron entry | `0 3 * * * /opt/scripts/backup.sh` |
| Retención local | 30 días |
| Retención offsite | 90 días en Backblaze B2 |
| Tamaño actual | {{XX GB}} comprimido |

### Backup de uploads

| Campo | Valor |
|---|---|
| Path local | `/data/{{project}}/uploads` |
| Path remoto | `b2://{{bucket}}/uploads/` |
| Comando | `rsync -avz --delete` |
| Frecuencia | Diaria post backup DB |

### Verificar que los backups funcionan (semanal)

```bash
# Verificar último backup DB existe y tiene >100KB
ls -lh /backups/db-$(date +%Y-%m-%d).sql.gz

# Verificar que B2 los recibe
b2 ls b2://{{bucket}}/ | tail -5

# Probar restore en ambiente staging (mensual idealmente)
# Ver "Procedimiento: Restaurar DB completa" abajo
```

⚠️ **Backup que nunca se testea NO es backup**. Hacer un restore real cada mes.

---

## 🚨 Procedimientos de emergencia

### 1. El VPS no responde (down total)

**Síntomas**: `ping {{IP}}` falla, SSH timeout, app inaccesible.
**Severidad**: 🚨 Catástrofe
**Esfuerzo**: 15-60 min

#### Pasos
1. Verificar status del provider:
   - Contabo: status.contabo.com
   - Hetzner: status.hetzner.com
   - DigitalOcean: status.digitalocean.com
2. Si provider tiene incidente → **esperar** (no hay nada que vos puedas hacer)
3. Si provider OK pero VPS down → consola web del provider → restart VPS
4. SSH retry: `ssh root@{{IP}}`
5. Si tras restart sigue down → escalation: ticket al provider
6. **Si todo perdido** → restaurar de snapshot (los providers ofrecen daily snapshots)

#### Verificación
- `curl https://{{dominio}}/api/health` → 200
- Login OK desde browser

---

### 2. La DB está corrupta / perdió datos

**Síntomas**: errores `permission denied`, `relation does not exist`, datos incoherentes.
**Severidad**: 🚨 Catástrofe (data loss)
**Esfuerzo**: 30-90 min

#### Pasos
1. **PARAR la app inmediatamente** para evitar más escrituras:
   ```bash
   docker service scale {{stack}}_app=0
   ```
2. **Snapshot del estado actual** (por si tenés que comparar):
   ```bash
   docker exec {{postgres-container}} pg_dump -U postgres {{db}} > /tmp/corrupt-snapshot.sql
   ```
3. **Identificar último backup limpio**:
   ```bash
   ls -lh /backups/db-*.sql.gz | tail -10
   ```
4. **Restaurar desde backup**:
   ```bash
   # Drop la DB corrupta
   docker exec -it {{postgres-container}} psql -U postgres -c "DROP DATABASE {{db}};"
   # Crear vacía
   docker exec -it {{postgres-container}} psql -U postgres -c "CREATE DATABASE {{db}};"
   # Restaurar
   gunzip -c /backups/db-YYYY-MM-DD.sql.gz | docker exec -i {{postgres-container}} psql -U postgres {{db}}
   ```
5. **Verificar row counts** críticos coinciden con expectation:
   ```sql
   SELECT count(*) FROM users;
   SELECT count(*) FROM {{tabla_critica}};
   ```
6. **Levantar la app**:
   ```bash
   docker service scale {{stack}}_app=1
   ```
7. **Smoke test manual** de funcionalidad core
8. **Post-mortem**: documentar en [`known-issues.md`](known-issues.md) qué pasó y por qué

#### Verificación
- App responde 200
- Login OK
- Row counts coinciden con pre-incidente (o con el último backup)

---

### 3. Deploy roto bloquea producción

**Síntomas**: app crashea al boot, 502/503 sostenido, healthcheck falla.
**Severidad**: 🚨 Outage
**Esfuerzo**: 5-15 min (con rollback rápido)

#### Pasos
1. **Rollback inmediato** al deploy anterior:
   ```bash
   docker service update --rollback {{stack}}_app
   ```
2. Si rollback no funciona → deploy manual de la imagen anterior:
   ```bash
   docker service update --image {{PROJECT_NAME}}:{{tag-anterior}} {{stack}}_app
   ```
3. Verificar healthcheck pasa:
   ```bash
   curl https://{{dominio}}/api/health
   docker service ps {{stack}}_app  # ver status replicas
   ```
4. **NO debuggear con producción rota** — siempre rollback primero, fix después en local
5. Reproducir el bug en local, fixear, redeploy

---

### 4. Disk lleno (>90%)

**Síntomas**: writes fallando, app lenta, errores `no space left on device`.
**Severidad**: 🚨 Crítica
**Esfuerzo**: 15-30 min

#### Pasos rápidos
1. Identificar qué llena:
   ```bash
   df -h
   du -sh /var/lib/docker /var/log /backups /data
   ```
2. **Limpieza segura**:
   ```bash
   # Logs antiguos
   journalctl --vacuum-time=7d
   # Imágenes Docker no usadas
   docker image prune -a -f
   # Build cache
   docker builder prune -a -f
   # Backups viejos (>30 días)
   find /backups -name '*.sql.gz' -mtime +30 -delete
   ```
3. Si sigue lleno → **upgrade plan** del VPS (ver [`infrastructure.md`](infrastructure.md))

---

### 5. Ataque DDoS / spike de tráfico anormal

**Síntomas**: CPU 100% sostenido, latencia altísima, requests desde IPs raras.
**Severidad**: 🚨 Crítica
**Esfuerzo**: 5-30 min

#### Pasos
1. **Activar Cloudflare proxy** (si no está):
   - Cloudflare DNS → toggle proxy ON
   - WAF → "I'm under attack mode"
2. Ver IPs sospechosas:
   ```bash
   docker logs {{traefik-container}} | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sort | uniq -c | sort -rn | head -20
   ```
3. Banear top abusers en Traefik:
   ```yaml
   # En traefik dynamic config
   http:
     middlewares:
       blocklist:
         ipAllowList:
           sourceRange: ["xxx.xxx.xxx.xxx"]  # deny list
   ```
4. Si persiste → escalación a Cloudflare Pro ($20/mes) con bot management

---

### 6. Certificate SSL expirado / Traefik no emite cert

**Síntomas**: browser muestra "Not Secure", `curl` da SSL error.
**Severidad**: 🟠 Alta
**Esfuerzo**: 10-20 min

#### Pasos
1. Verificar cert actual:
   ```bash
   echo | openssl s_client -connect {{dominio}}:443 2>/dev/null | openssl x509 -noout -dates
   ```
2. Ver logs de Traefik:
   ```bash
   docker logs {{traefik-container}} 2>&1 | grep -i acme | tail -50
   ```
3. Causas comunes:
   - **Rate limit Let's Encrypt** → esperar (5 fails/hora máximo)
   - **DNS mal configurado** → verificar A record apunta al VPS
   - **Puerto 80 cerrado** → Let's Encrypt necesita HTTP challenge
4. Forzar renovación borrando acme.json (CUIDADO: rate limit):
   ```bash
   docker exec {{traefik-container}} rm /letsencrypt/acme.json
   docker service update --force {{stack}}_traefik
   ```

---

## 📋 Post-mortem template

Cuando ocurre un incidente, **siempre** documentar después:

```markdown
## Incidente YYYY-MM-DD HH:MM — {{título}}

**Duración**: {{X min}}
**Severidad**: {{🚨/🟠/🟡}}
**Impacto**: {{cuántos usuarios afectados, qué features bloqueadas}}

### Timeline
- HH:MM — síntoma detectado
- HH:MM — diagnóstico iniciado
- HH:MM — fix aplicado
- HH:MM — verificado resuelto

### Root cause
{{explicación técnica de por qué pasó}}

### Lección
{{qué cambiamos para evitarlo en el futuro}}

### Action items
- [ ] {{cambio en código / config / proceso}}
- [ ] {{test/monitoring que detectaría esto antes}}
```

Ver [`known-issues.md`](known-issues.md) sección "Incidentes históricos" para ejemplos.

---

## Referencias

- [`infrastructure.md`](infrastructure.md) — topología (qué está dónde)
- [`monitoring.md`](monitoring.md) — cómo detectar problemas antes que exploten
- [`runbook.md`](runbook.md) — procedures rutinarios (no de emergencia)
- [`known-issues.md`](known-issues.md) — histórico de incidentes + lessons
