# 💸 cloud-services-costs.md — Qué cuesta cada servicio cuando crece

> **Última actualización**: {{YYYY-MM-DD}}
> **Audiencia**: vos al planear escalado o cuando llegan las primeras facturas
> **Propósito**: ver el costo REAL del stack Vercel cuando crecés (no solo el free tier)
> **Cuándo actualizar**: cuando cambian precios de algún servicio managed

> 🌐 **Aplica al path Vercel/Managed**.
> Si vas con VPS, los costos son fijos — ver [`costs.md`](costs.md).

---

## 🎯 TL;DR — El path Vercel escala caro

| Etapa | Usuarios | Costo total mensual estimado |
|---|---|---|
| MVP / portfolio | <100 visits/mes | **$0** (todo free tier) |
| Primeros usuarios | 100-1000 visits/mes | **$0** (sigue free tier) |
| Validación | 1k-10k visits/mes | **$20-50** (algunos servicios pagan) |
| Crecimiento | 10k-50k visits/mes | **$70-150** |
| Tracción | 50k-100k visits/mes | **$150-400** |
| Escala | 100k+ visits/mes | **$400-1000+** |

→ A partir de "Validación", **VPS Contabo es más barato** ($5-50/mes fijo).

---

## 💰 Vercel — costos por tier

| Plan | Costo | Bandwidth | Compute | Build minutes | Cuándo necesitarlo |
|---|---|---|---|---|---|
| **Hobby (free)** | $0 | 100 GB/mes | 100h/mes | 6000/mes | Apps personales |
| **Pro** | $20/usuario/mes | 1 TB | 1000h | 24000 | Equipo + apps comerciales |
| **Enterprise** | Custom | Custom | Custom | Custom | Empresas grandes |

### Cuándo te excede el free tier
- Bandwidth: si tu app se viraliza (1 post en Reddit = puede ser 50 GB en horas)
- Compute: apps con muchas API routes o functions
- Custom domains: free permite pero algunas features (analytics avanzados) son Pro-only

---

## 💰 Supabase — costos por tier

| Plan | Costo | DB size | Bandwidth | Active users | Storage |
|---|---|---|---|---|---|
| **Free** | $0 | 500 MB | 5 GB | 50k MAU | 1 GB |
| **Pro** | $25/mes | 8 GB | 250 GB | 100k MAU | 100 GB |
| **Team** | $599/mes | Custom | Custom | Custom | Custom |

### Cuándo te excede el free tier
- DB > 500 MB → Pro mandatory
- Si usás Supabase Storage para uploads → free tier 1GB se llena rápido
- Pausa automática free tier: si tu proyecto **no se usa por 1 semana** → suspendido (reactivable)

### Add-ons que suman
- Compute upgrades (más CPU para Postgres): $10-110/mes extra
- Read replicas: $25/mes cada una
- PITR (point-in-time recovery): $100/mes Pro

---

## 💰 Clerk (auth) — costos por tier

| Plan | Costo | MAU incluidos | Features |
|---|---|---|---|
| **Free** | $0 | 10,000 MAU | Email/social/passwordless |
| **Pro** | $25/mes | 10k included + $0.02/MAU extra | + organizations + advanced |
| **Enterprise** | Custom | | + SAML + audit logs |

### Add-ons
- SMS verification: $0.04/SMS
- Hot data export: incluido en Pro
- Multi-session: incluido

### Alternativa más barata
- **NextAuth.js** (open source, gratis pero más config)
- **Better Auth** (mismo perfil que Clerk pero self-hostable)
- **Supabase Auth** (gratis si ya pagás Supabase Pro)

---

## 💰 Resend (email) — costos

| Plan | Costo | Emails/mes |
|---|---|---|
| **Free** | $0 | 3,000 (100/day) |
| **Pro** | $20/mes | 50,000 |
| **Scale** | $90/mes | 500,000 |

### Alternativas más baratas
- **Mailgun**: $35/mes para 50k → más caro pero más maduro
- **Postmark**: $15/mes para 10k → económico para transactional
- **AWS SES**: $0.10/1000 emails → más barato pero más setup

---

## 💰 Stripe (pagos)

| Concepto | Costo |
|---|---|
| Transacción tarjeta | 2.9% + $0.30 |
| Transacción internacional | +1.5% |
| Disputed chargeback | $15 |
| Cuenta mensual | $0 (no hay fee fijo) |

⚠️ Stripe no tiene "plan gratis" — siempre te cobra por transacción.
✅ Pero NO cobra si no vendés.

### Alternativas LATAM
- **Mercado Pago**: 4.99% + IVA en muchos países LATAM (más caro que Stripe pero local)
- **Lemon Squeezy**: Merchant of Record (te factura ellos los impuestos) — 5% + $0.50

---

## 📊 Calculadora — estima tu costo Vercel/managed

Llená con tus números esperados:

```
Bandwidth/mes:       __ GB    (Vercel free: 100 GB)
Compute/mes:         __ h     (Vercel free: 100h)
DB size:             __ MB    (Supabase free: 500 MB)
Active users/mes:    __       (Clerk free: 10k)
Emails/mes:          __       (Resend free: 3000)
Ventas/mes:          $__      (Stripe: 2.9% + $0.30 c/u)

Costo total estimado:
  Vercel:    $__ (Hobby $0 / Pro $20 si pasás)
  Supabase:  $__ (Free $0 / Pro $25)
  Clerk:     $__ (Free $0 / Pro $25)
  Resend:    $__ (Free $0 / Pro $20)
  Stripe:    $__ (% de ventas)
  ─────────────────────────────────────
  TOTAL:     $__/mes
```

---

## 🚀 Cuándo migrar a path VPS

⚠️ La regla simple: **si tu costo managed total >$50/mes sostenido, mudate a VPS Contabo**.

| Tu costo Vercel+co | Acción recomendada |
|---|---|
| $0-30/mes | Quedate en Vercel, es lo más fácil |
| $30-60/mes | Considerá VPS si tenés tiempo de migrar |
| $60+/mes | **Migrá YA** — un VPS Contabo VDS M ($48/mes) te da MÁS poder por menos plata |

### Cómo migrar

1. `harness upgrade --to=vps` — el harness te genera los docs y configs
2. Tu agente AI te guía paso a paso
3. Tiempo realista: 1-3 días de trabajo (no full-time)
4. Lo más doloroso: migrar la DB de Supabase a Postgres self-hosted (pero existen scripts)

---

## Referencias

- [`tech-context.md`](tech-context.md) — stack actual
- [`decisions.md`](decisions.md) — ADRs sobre elección de servicios
- [`deploy-to-vercel.md`](deploy-to-vercel.md) — setup de cada servicio managed
- [`costs.md`](costs.md) — comparativa con costos VPS si migrás
