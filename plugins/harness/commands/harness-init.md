---
name: harness-init
description: Bootstrap el AI Agent Harness en este proyecto. Claude te hace 18 preguntas en el chat y crea la estructura de docs apropiada para tu app. Cero terminal necesaria.
---

# /harness-init — Wizard interactivo del AI Agent Harness

Invocá la skill `harness-init` y empezá el wizard guiado.

## Lo que va a pasar

1. Te voy a hacer 18 preguntas (en modo standard) sobre tu proyecto, de a una por vez
2. Vos respondés en lenguaje natural en el chat — sin terminal, sin bash
3. Según tus respuestas, te ramifico a uno de 3 caminos:
   - 💻 **Local-only** — app que vive en tu compu ($0/mes)
   - 🌐 **Vercel/cloud managed** — fácil para principiantes ($0 free tier)
   - 🚀 **VPS Contabo** (patrón Publiafy) — comercial vendible ($5-48/mes)
4. Al final genero **todos los archivos** automáticamente:
   - `docs/` con 8-17 markdown skeletons (depende del path)
   - `CLAUDE.md` con tu contexto cargado
   - Configs Docker si elegiste VPS
   - `git init` + primer commit si pediste

## Modos

- `/harness-init` — wizard estándar (18 preguntas, ~8 min)
- `/harness-init quick` — solo 5 esenciales (~2 min)
- `/harness-init deep` — 18 + edge cases (i18n, multi-tenant, compliance, etc.)

## Después del wizard

Tu agente AI (yo) tengo todo el contexto en `CLAUDE.md` + `docs/`. Empezás a codear sabiendo que entiendo tu proyecto completo.

---

**Ahora invocá la skill `harness-init` y empezá las preguntas.**
