# 📊 monitoring.md — Cómo monitoreamos la app

> **Última actualización**: {{YYYY-MM-DD}}
> **Audiencia**: vos + tu agente AI cuando algo no anda como esperás
> **Propósito**: cómo saber que la app está sana sin tener que abrirla
> **Cuándo actualizar**: cuando se agrega un check, alerta o dashboard

> 🚀 **Aplica al path VPS**. Para Vercel/Local los checks son más simples
> (Vercel tiene monitoring built-in, Local no necesita).

---

## 🩺 Healthchecks

### Endpoint principal `/api/health`

```javascript
// Backend implementation
app.get('/api/health', async (req, res) => {
  try {
    await db.query('SELECT 1');  // DB up?
    return res.json({ ok: true, ts: Date.now() });
  } catch (e) {
    return res.status(503).json({ ok: false, error: 'db_unreachable' });
  }
});
```

### Docker HEALTHCHECK

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD wget -q -O - http://localhost:3000/api/health || exit 1
```

→ Docker reinicia el container automáticamente si falla 3 veces seguidas (90s).

---

## 📡 External uptime monitoring

### UptimeRobot (recomendado para empezar — gratis)

| Monitor | URL | Intervalo | Alerta a |
|---|---|---|---|
| App home | `https://{{dominio}}` | 5 min | Email + Telegram |
| API health | `https://{{dominio}}/api/health` | 5 min | Email + Telegram |
| Login endpoint | `https://{{dominio}}/login` | 15 min | Email |

**Setup**: https://uptimerobot.com → free tier permite 50 monitores cada 5min.

### Alternativas
- **Better Stack** (paid, $19/mes) — más pulido, status page público incluido
- **StatusCake** (free hasta 10 monitors)
- **Cronitor** (paid pero excelente para cron jobs)

---

## 🚨 Alertas (cómo te enterás de problemas)

### Canal preferido del owner

| Severidad | Canal | Tiempo de respuesta esperado |
|---|---|---|
| 🚨 Catástrofe (app down) | SMS / push del UptimeRobot | <5 min |
| 🟠 Alta (errores recurrentes) | Email | <1h |
| 🟡 Media (warnings) | Email digest diario | <24h |
| 🟢 Info | Slack/Discord channel | Cuando puedas |

### Configurar Telegram alerts (gratis, instant)

1. Crear bot: hablar con `@BotFather` en Telegram → `/newbot`
2. Anotar el token
3. En UptimeRobot: Settings → Notifications → Telegram → pegar token
4. Conectar el bot al chat: hablar con tu bot → `/start`

---

## 📈 Métricas / Dashboards

### Opción 1: básico (recomendado para arranque)

**Sin dashboard custom**. Solo UptimeRobot + logs.

- `docker stats` → CPU/RAM por container en tiempo real
- `docker logs --tail=100 -f {{container}}` → logs en vivo
- UptimeRobot dashboard → uptime histórico

### Opción 2: Grafana + Prometheus (cuando crezcas)

```yaml
# Agregar a docker-stack.yml cuando lo necesites
prometheus:
  image: prom/prometheus
  # ...
grafana:
  image: grafana/grafana
  # ...
```

**Cuándo agregar Grafana**: cuando ya tenés >20 negocios activos pagando y necesitás ver tendencias (no solo uptime).

### Opción 3: Better Stack / Datadog / New Relic

Para apps con SLAs serios. Costo escala con uso. Para principiantes: defer.

---

## 📋 Logs

### Logs de Docker

```bash
# Container específico
docker logs --tail=200 -f {{stack}}_{{service}}

# Todos los logs del stack
docker service logs --tail=50 -f {{stack}}_app
```

### Logs centralizados (cuando crezcas)

Opciones:
- **Better Stack Logs** (paid) — search + alertas
- **Loki + Grafana** (free, self-hosted) — más setup
- **Vector + ClickHouse** (free pero complejo)

**Para empezar**: NO centralizar. `docker logs` es suficiente hasta ~5 servicios.

### Retención
- Stdout normal: 14 días (configurar en `docker-stack.yml`)
- Error logs: 90 días
- Audit logs (acciones admin): 1 año

```yaml
# En docker-stack.yml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "100m"
        max-file: "10"
```

---

## 🐛 Error tracking

### Sentry (recomendado)

```javascript
// Backend
const Sentry = require('@sentry/node');
Sentry.init({
  dsn: process.env.SENTRY_DSN,
  tracesSampleRate: 0.1,  // 10% de requests para perf monitoring
});
```

**Plan gratis**: 5k errors/mes — alcanza para arrancar.
**Cuándo pagar Sentry**: cuando errores >5k/mes (= upgrade $26/mes).

### Alternativas open source
- **GlitchTip** (Sentry-compatible API, self-hosted, free)
- **Highlight.io**

---

## 💯 SLAs / Objetivos

| Métrica | Target | Cómo medirla |
|---|---|---|
| Uptime mensual | 99.5% (3.5h/mes downtime aceptable) | UptimeRobot |
| Latencia P50 | <200ms | Grafana / Sentry perf |
| Latencia P95 | <500ms | idem |
| Error rate | <0.5% requests | Sentry |
| Time to recover | <15 min de outages | Manual tracking |

---

## Referencias

- [`infrastructure.md`](infrastructure.md) — qué hay deployado
- [`disaster-recovery.md`](disaster-recovery.md) — qué hacer cuando algo falla
- [`runbook.md`](runbook.md) — procedimientos de check rutinarios
