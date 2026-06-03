# 🔌 integrations.md — APIs externas y quirks

> **Última actualización**: {{YYYY-MM-DD}}
> **Audiencia**: agente que va a tocar código de integración externa.
> **Propósito**: catálogo de integraciones con quirks no obvios.
> **Cuándo actualizar**: cuando se agrega integración o se descubre un quirk.

---

## Índice rápido

| # | Servicio | Tipo | Status |
|---|----------|------|--------|
| 1 | ... | OAuth | ✅ live |

---

## 1. {{Service Name}}

**Tipo**: OAuth / API key / Webhook / SDK
**Docs oficiales**: https://...
**Status**: ✅ live / 🟡 sandbox / ⏳ pendiente

### Auth
{{Cómo nos autenticamos}}

### Endpoints / SDK usados

| Endpoint | Propósito |
|----------|-----------|
| `GET /...` | ... |

### Variables de entorno

- `SERVICE_API_KEY`
- `SERVICE_CLIENT_ID`

### Rate limits

- {{X calls/min}}

### Retry strategy

{{Si falla, qué hace nuestro código}}

### Webhooks (si aplica)

- URL en {{PROJECT}}: `/api/webhooks/X`
- Verification: HMAC SHA256 / token / nothing
- Retry policy del proveedor: {{X días / N reintentos}}

### Costos

{{Modelo de pricing del proveedor + cuánto pagamos hoy}}

### ⚠️ Gotchas y quirks

- **Quirk 1**: contexto + cómo lo manejamos
- **Quirk 2**: ...

### Archivos relevantes

- `backend/services/X.js`
- `backend/routes/X.js`

### Status migration / next steps

{{Si está en sandbox: qué falta para production}}

---

## Patrones cross-integration

(comunes a varias integraciones — encriptación, idempotency, raw body para HMAC, etc.)
