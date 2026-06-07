# 🛠️ runbook.md — Procedimientos operacionales

> **Última actualización**: {{YYYY-MM-DD}}
> **Audiencia**: alguien (humano o agente) que debe ejecutar una acción rápido.
> **Propósito**: pasos exactos para situaciones reales (emergencias, deploys, rotación de secrets).
> **Cuándo actualizar**: cuando se descubre un nuevo procedure o cambia uno existente.

---

## 🚨 Emergencias

### 1. Producción no responde
**Cuándo usar**: 404 / 5xx en endpoint principal.
**Severidad**: 🚨 emergencia
**Esfuerzo**: ~15-30 min

#### Pasos
1. `curl -I https://app.com/api/health` — ver código de respuesta
2. SSH al VPS / acceder dashboard cloud provider
3. Ver estado del container/service principal
4. Leer últimos 200 logs
5. Identificar pattern del crash

#### Verificación
- `curl /api/health` → 200

#### Si falla
- Rollback: `git revert <commit> && deploy`

#### Referencias
- `lessons-learned.md` sección Deploy / Operations
- `known-issues.md` para patterns similares

---

### 2. {{Otro escenario crítico}}
(template)

---

## 🚀 Deploy

### 7. Deploy normal
**Cuándo usar**: cambios admin-side seguros.
**Severidad**: 🟡 normal
**Esfuerzo**: ~5-10 min

#### Pasos
1. ...
2. ...

#### Verificación
- ...

---

## 🔑 Secrets / Tokens

### 11. Rotar {{Service}} API key
**Cuándo usar**: rotación periódica o post-leak.
**Severidad**: 🟠 alta
**Esfuerzo**: ~15 min

#### Pasos
1. Generar key nueva en dashboard del provider
2. Update env var en Portainer / Secret Manager
3. Redeploy service
4. Verificar con curl que funciona
5. Revocar key vieja

---

## 🔧 Maintenance

### 16. Limpiar uploads viejos
(template)

---

## Convenciones del runbook

Cada procedure sigue esta estructura:
- **Título**
- **Cuándo usar**: situación específica
- **Severidad**: 🚨/🟠/🟡/🟢
- **Esfuerzo**: tiempo estimado
- **Pre-requisitos** (opcional)
- **Pasos** numerados con comandos copy-pasteables
- **Verificación**: cómo confirmar que funcionó
- **Si falla**: plan B / escalation
- **Referencias**: links a known-issues / lessons-learned / memorias

**Regla**: comandos copy-pasteables (no pseudo-código). Si el comando depende del entorno (`$VAR`), documentar dónde se setea.
