---
name: harness-upgrade
description: Migrá tu proyecto entre paths del harness (local→vercel, vercel→vps, etc.). Te guío paso a paso sin perder docs existentes.
---

# /harness-upgrade — Migrar entre paths

Si tu proyecto creció y querés cambiar de path (ej: tu app personal en local se volvió comercial y querés VPS), te ayudo a migrar.

## Uso

- `/harness-upgrade to=vercel` — migrar a path Vercel
- `/harness-upgrade to=vps` — migrar a path VPS comercial
- `/harness-upgrade to=local` — bajar a local (raro pero posible)

## Lo que hago

1. Detecto tu path actual leyendo `docs/decisions.md` ADR-001
2. Te pregunto las decisiones específicas del nuevo path (ej: si vas a VPS, qué tier de Contabo)
3. Genero los docs nuevos del path (sin tocar los existentes)
4. Agrego un ADR nuevo en `decisions.md` documentando la migración
5. Te doy un checklist de pasos manuales (configurar VPS, migrar DB, etc.)

**NO destruyo nada de lo que ya tenés** — solo agrego lo necesario para el path nuevo.

---

**Ahora invocá la skill `harness-init` con el flag de upgrade activado.**
