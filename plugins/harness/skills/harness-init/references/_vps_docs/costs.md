# 💰 costs.md — Costos mensuales de operación

> **Última actualización**: {{YYYY-MM-DD}}
> **Audiencia**: vos + decisiones de cuándo upgradear
> **Propósito**: tracking honesto de cuánto cuesta operar la app
> **Cuándo actualizar**: cada vez que se agrega/saca un servicio o cambia un plan

> 🚀 **Crítico para path VPS** (donde vos pagás todo).
> En Vercel/Local, los costos son más simples — pero igual sirve documentar.

---

## 📊 Tier actual

| Campo | Valor |
|---|---|
| Tier VPS | {{Cloud VPS 10 / 20 / 30 / VDS M}} |
| Migré a este tier | {{YYYY-MM-DD}} |
| Razón del tier actual | {{Arranque MVP / validando / escalando con clientes}} |
| Capacidad teórica | {{~200 / ~800 / ~2000 usuarios activos}} |

---

## 💵 Costos fijos mensuales

| Item | Costo USD/mes | Notas |
|---|---|---|
| VPS Contabo {{plan}} | $5-48 | Ver "tiers de upgrade" abajo |
| Dominio principal | $1 | Renueva {{fecha}} |
| Backblaze B2 (backups) | $0-5 | ~$0.005/GB/mes |
| Cloudflare | $0 | Free tier alcanza |
| Email transaccional (Resend) | $0 | Free tier: 3000/mes |
| Error tracking (Sentry) | $0 | Free tier: 5k errors/mes |
| Monitoring (UptimeRobot) | $0 | Free tier: 50 monitors |
| **Total fijo aproximado** | **$6-55** | |

⚠️ Apenas algún servicio pase el free tier → suma a la tabla con el nuevo plan.

---

## 💱 Costos variables (escalan con uso)

| Servicio | Pricing | Estimado/mes actual |
|---|---|---|
| OpenAI / Gemini API | Por tokens consumidos | ${{X}} |
| Stripe fees | 2.9% + $0.30/transacción | escala con ventas |
| Twilio SMS | $0.0079/SMS | escala con uso |
| Push notifications (OneSignal) | $0 hasta 10k subs | $0 |
| **Total variable estimado** | | **${{X}}** |

---

## 🎯 Tiers de Contabo — cuándo upgradear

| Tier | Specs | Costo USD/mes | Capacidad | Cuándo upgradear |
|---|---|---|---|---|
| **Cloud VPS 10** | 4 vCPU shared / 6 GB RAM / 100 GB | $5-7 | 0-200 users | RAM uso >70% sostenido |
| **Cloud VPS 20** | 6 vCPU shared / 12 GB / 200 GB | $7-9 | 200-800 users | Disk >70% o load >2 |
| **Cloud VPS 30** | 8 vCPU shared / 24 GB / 200 GB NVMe | $15-20 | 800-2000 users | RAM o load sostenido alto |
| **VDS M** | 4 vCPU **dedicated** / 32 GB / 240 GB NVMe | $48 | 2000-5000 users | Querés performance garantizada (cores no shared) |
| **VDS L** | 6 vCPU dedicated / 48 GB / 360 GB NVMe | $69 | 5000-10000 users | Negocio establecido |
| **VDS XL** | 8 vCPU dedicated / 64 GB / 480 GB NVMe | $89 | 10000+ users | Enterprise |

### Cuándo NO upgradear (aunque parezca obvio)

- ❌ "Porque sí, por las dudas" → desperdicio de plata
- ❌ "Por un día de spike" → ver si es sostenido por 7+ días
- ❌ "Porque hay un nuevo plan más caro" → solo si las métricas lo justifican

### Cuándo SÍ upgradear

- ✅ RAM utilización >70% sostenida 7+ días
- ✅ Disk >70% (alertar a 60% para tener tiempo)
- ✅ Postgres DB >50% del disk total
- ✅ Latencia P95 endpoints >500ms sostenido (no es spike)
- ✅ CPU load average >2.5 sostenido

---

## 🧮 Break-even analysis

Calculá cuántos usuarios necesitás pagando para justificar tus costos:

```
Costos fijos mensuales:          $6
Costo variable por user (LLM, etc): $0.10/user/mes
Precio por user:                 $9.99/mes
Stripe fees:                     2.9% + $0.30 = ~$0.59/transacción

Margen neto por user pagando:    $9.99 - $0.59 - $0.10 = $9.30
Users necesarios para break-even: 6 / $9.30 = 0.65 users

→ Con 1 cliente pagando ya cubrís costos fijos ($6/mes).
```

**Hacé el cálculo con tus números reales** y actualizá esto cuando cambien.

---

## 📅 Histórico de cambios de plan

| Fecha | De → A | Razón | Costo delta |
|---|---|---|---|
| {{YYYY-MM-DD}} | — → Cloud VPS 10 | Setup inicial MVP | +$5/mes |
| | | | |

---

## 🛑 Costos que SUMAN sin darse cuenta

Cosas que principiantes pagan sin notar — auditalas mensualmente:

- [ ] **Suscripciones SaaS olvidadas** (Figma, Notion, Canva Pro)
- [ ] **Trials que se convirtieron en paid** (cobran a los 14 días sin avisar)
- [ ] **APIs en uso bajo pero por encima del free tier** ($5-20/mes cada una)
- [ ] **Storage que crece sin límite** (S3 sin lifecycle policies)
- [ ] **CDN bandwidth** (Vercel cobra $$$ si te viralizás)

**Acción mensual**: revisar `tarjetas → suscripciones` y cancelar lo que no uses.

---

## 🎯 Filosofía de costos para este proyecto

**Empezamos cheap, upgradeamos cuando lo justifique el revenue.**

NO:
- ❌ Comprar tier alto "para estar tranquilo"
- ❌ Pagar Sentry/Datadog/etc desde día 1 sin usuarios

SÍ:
- ✅ Usar free tiers hasta el límite
- ✅ Documentar cada decisión de upgrade con su trigger métrico
- ✅ Revisar costos cada mes (5 min)

---

## Referencias

- [`infrastructure.md`](infrastructure.md) — qué tier actual + topología
- [`monitoring.md`](monitoring.md) — cómo medir las métricas que disparan upgrades
- [`decisions.md`](decisions.md) — ADRs sobre elecciones de stack/hosting
