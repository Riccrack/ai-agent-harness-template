# 🔐 security.md — Threat model + secret handling

> **Última actualización**: {{YYYY-MM-DD}}
> **Audiencia**: dev/agent que toca código sensible + auditor externo.
> **Propósito**: modelo de seguridad del proyecto.
> **Cuándo actualizar**: cuando hay cambio de seguridad o threat nuevo detectado.

---

## 1. Threat Model

### Atacantes
- Script kiddies probando vulns conocidos
- Competidores haciendo scraping
- Abusadores de trial / free tier
- Bots de spam masivo
- {{Otros relevantes al proyecto}}

### Assets a proteger
- User data (PII, emails, perfiles)
- Tokens OAuth de plataformas conectadas
- BYOK keys / API keys de users
- Payment data (PCI compliance)
- Session tokens

### Attack vectors documentados
- CSRF
- XSS (stored / reflected)
- SQL injection
- Token theft via XSS o MitM
- SSRF en uploads / fetch externos
- Brute force login
- Account takeover via OAuth flaws

---

## 2. Authentication

- **JWT structure / expiration / refresh**: detalle.
- **OAuth flows externos**: lista de providers.
- **Anti trial-abuse measures**: signup fingerprinting / device check.

## 3. Authorization

- **Permission model**: rango / capabilities / roles.
- **Admin caps**: `manage_X` con cap-based access control.
- **Audit log**: dónde se loguea, retention.

## 4. Secret Management

- **Storage**: `.env` en VPS / Secret Manager (NUNCA en repo).
- **Encryption at-rest**: AES-256-GCM para secrets sensibles.
- **Rotation procedure**: link a [`runbook.md`](runbook.md) sección Secrets.

## 5. HTTPS / TLS

- **Cert provider**: Let's Encrypt vía Traefik / equivalente.
- **HSTS**: max-age + includeSubDomains.
- **Renewal automation**: cómo se renueva.

## 6. Headers de Seguridad

- helmet config con CSP/HSTS/X-Frame-Options/nosniff/etc.

## 7. CORS Policy

- Whitelist de orígenes permitidos
- Excepciones documentadas (widget público, etc.)

## 8. Rate Limiting

- Por user / por IP / por endpoint
- Library: `express-rate-limit` con `ipKeyGenerator` (IPv6 safe)
- Endpoints especialmente protegidos: auth, billing, BYOK

## 9. Webhook Verification

- HMAC SHA256 con raw body
- Verificación obligatoria antes de cualquier acción

## 10. Privacy Compliance

- GDPR/CCPA data deletion endpoint
- Privacy Policy live URL
- Cookie consent (si aplica)
- Data Deletion Instructions URL

## 11. Audit Trail

- `admin_audit_log` table (o equivalente)
- Qué se loguea: who/when/what/result
- Retention: {{N días}}

## 12. Security Incidents históricos

(vacío hasta que ocurra)

## 13. Anti-patterns (NO hacer)

- ❌ Tokens en query params (van en headers)
- ❌ CORS wildcard `*` en endpoints de auth
- ❌ `console.log` con tokens/PII en producción
- ❌ Hardcoded secrets en código
- ❌ Source maps expuestos en producción
- ❌ Rate limit sin `ipKeyGenerator` (CVE en IPv6)
- ❌ Webhook handler sin signature verify
- ❌ Permitir XSS via dangerouslySetInnerHTML sin sanitize
