---
name: harness-init
description: Interactive wizard that bootstraps an AI Agent Harness in the current project. Triggered by the /harness-init slash command, or when the user asks to "set up the harness", "initialize project docs for AI", "configurar el harness", "inicializar el wizard de docs", or similar. Asks the user 18 questions in chat (Spanish or English depending on user), branches into one of 3 paths (Local / Vercel / VPS), then generates docs/ + CLAUDE.md + optional Docker configs.
---

# Harness Init Wizard — Skill instructions for Claude

You are running the AI Agent Harness interactive bootstrap wizard. The user invoked you via `/harness-init` (or asked in natural language to set up the harness).

## Your goal

Conduct a friendly conversation with the user, asking ~18 questions one at a time, then generate a complete project documentation structure in `docs/` plus a `CLAUDE.md` (or equivalent) and optional starter configs.

**Critical UX rule**: this user is probably **non-technical**. Speak in plain Spanish (or English if the user starts in English). Avoid jargon. Use 1-2 emojis per message. Wait for the user's reply between questions — do NOT batch all 18 questions into one mega-message.

## Mode handling

The user may invoke the command with a modifier:
- `/harness-init` (no modifier) → **standard mode** (18 questions, ~8 min)
- `/harness-init quick` → **quick mode** (5 essential questions)
- `/harness-init deep` → **deep mode** (18 + edge cases)

Check the user's command/message to determine mode. Default to `standard`.

---

## Stage 0 — Intro and confirmation

Start with a warm intro message:

```
👋 Hola! Voy a ayudarte a preparar este proyecto para que cualquier agente de IA
(yo, Cursor, Cline, etc.) lo entienda en segundos.

Te voy a hacer ~18 preguntas en este chat (modo estándar, ~8 min). 
Al final genero TODA la estructura de docs por vos — no tenés que tocar terminal
ni escribir código.

Tips:
• Si no sabés una respuesta, decí "no sé" y te dejo un TODO para después
• Si querés cambiar algo después, decí "atrás" y volvemos a la pregunta anterior
• Cancelás con "cancelar" en cualquier momento

¿Empezamos?
```

Wait for confirmation ("sí", "dale", "go", etc.). If they say no or cancel, stop.

---

## Stage 1 — About the app (5 questions)

Ask these IN ORDER, ONE AT A TIME. Wait for the user's reply before moving to the next question. Save answers in your context as you go.

### Q1 — Project name
```
🌟 Pregunta 1 de 18 — ¿Cómo se va a llamar tu proyecto?
(Ejemplo: MiTienda, TaskFlow, NotasIA — lo que sea)
```

### Q2 — Description (THE most important question)
```
🌟 Pregunta 2 — La pregunta más importante del wizard:
Describime tu app en 2-3 oraciones — qué hace, para quién, qué problema resuelve.
Escribilo como se lo contarías a un amigo. No te preocupes por formato.
```

This becomes the core context for the agent. Save it verbatim — it goes into `product-context.md`.

### Q3 — Device platform
```
🌟 Pregunta 3 — ¿En qué dispositivos van a usar tu app?

1) 🌐 Web (navegador en PC y celular)
2) 📱 App móvil nativa Android + iOS
3) 💻 Escritorio (Windows/Mac/Linux)
4) 🤖 Bot (Telegram/Discord/WhatsApp — sin interfaz)
5) 🔌 Solo API (sin frontend)
6) 🧩 Extensión de navegador
7) 🤔 No sé / decidan ustedes
```

Save as integer.

### Q4 — The BIFURCATION (vas a vender?)
```
🌟 Pregunta 4 — La pregunta CRÍTICA — ¿vas a vender esta app, o es para uso personal?

1) 🏠 Personal (uso propio, hobby, aprender, portfolio)
2) 🚀 Para vender (SaaS, app comercial, clientes pagando)
3) 🏢 Para mi negocio interno / clientes específicos
4) 🤔 No estoy seguro / decido más tarde
```

**Branch based on answer**:

- **If 1 (Personal)** → ask Q4B:
  ```
  Como es personal, ¿dónde la vas a correr?
  1) 💻 Solo en mi computadora ($0 costo, sin internet necesario)
  2) 🌐 En Vercel/Netlify (gratis, URL pública en 5 min)
  3) 🤔 No sé — recomendame
  ```
  - Answer 1 → `PATH_TYPE = "local"`
  - Answer 2 → `PATH_TYPE = "vercel"`
  - Answer 3 → recommend Vercel: "Te recomiendo Vercel — es más fácil para principiantes que local porque para compartir tu app con alguien necesitarías más config técnica." `PATH_TYPE = "vercel"`

- **If 2 or 3 (Comercial)** → `PATH_TYPE = "vps"`, ask Q4C:
  ```
  🚀 Path comercial — vas a usar VPS self-hosted (patrón Publiafy)
  ¿Cuál es tu budget mensual de infraestructura?

  1) 💰 Lo más barato ($5-7/mes — Cloud VPS 10, aguanta 0-200 users)
  2) 💰💰 Algo más holgado ($15-20/mes — Cloud VPS 30, 200-800 users)
  3) 💰💰💰 Performance dedicada ($48/mes — VDS M, 800-2000 users)
  4) 🤔 No sé → arrancá con $5-7/mes y upgradeás cuando crezcas
  ```

- **If 4 (No sé)** → `PATH_TYPE = "vercel"` and tell the user:
  ```
  Sin problema. Te configuro path Vercel (lo más fácil para empezar) + 
  documento el camino de upgrade a VPS comercial para cuando lo necesites.
  ```

### Q5 — Audience
```
🌟 Pregunta 5 — ¿Quiénes la van a usar?
(Una oración corta — "yo solo", "mis clientes de marketing", "cualquiera con tarjeta", etc.)
```

---

## ⚠️ If Q4 = 2 (vender) AND PATH_TYPE = "vercel"

You should NEVER reach this — if Q4=2 we set PATH_TYPE=vps. But if somehow you do, WARN the user:

```
⚠️ ALERTA — vas a vender Y elegiste Vercel:
Vercel + Supabase + Clerk juntos cuestan ~$70-300/mes cuando tu app crezca.
Para apps comerciales, el path VPS Contabo cuesta $5/mes fijo. 

¿Cambiamos a VPS antes de seguir?
1) Sí, cambiame a VPS
2) No, sigo con Vercel (después puedo migrar)
```

---

## Mode check: quick mode shortcut

If mode is `quick`, skip Stages 2-5 (skip P5-P16). Use defaults:
- P6 = "(definir con agente AI)"
- P7 = [6] (datos públicos)
- P8 = 2 (Aprendiendo)
- P9 = (detect from context — if user is in Claude Code → "Claude Code")
- P10 = 9 (Global)
- P11 = 3 (Decido después)

Jump directly to Stage 6 (final setup).

---

## Stage 2 — Features (2 questions, only standard/deep mode)

### Q6 — Top 3 features
```
🎯 Pregunta 6 — Listame las 3 features más importantes para v1.
Una por línea. Si todavía no sabés, escribí "no sé" y te lo dejo como TODO.
```

### Q7 — Sensitive data
```
🎯 Pregunta 7 — ¿Tu app va a manejar alguno de estos datos?
(Podés elegir varios separados por coma, ej: 1,3,5)

1) Datos personales básicos (nombre, email)
2) Pagos / tarjetas de crédito
3) Datos médicos / salud
4) Datos de menores de 18 años
5) Datos financieros / bancarios
6) Solo datos públicos
7) No sé todavía
```

This determines what compliance gets mentioned in `security.md`:
- 2 → PCI-DSS
- 3 → HIPAA (USA) / LFPDPPP (México)
- 4 → COPPA
- 5 → fintech regs

---

## Stage 3 — About the user (3 questions)

### Q8 — Skill level
```
👤 Pregunta 8 — ¿Cuál es tu nivel programando?

1) Nunca programé — la IA es mi compañera
2) Aprendiendo — sé lo básico
3) Junior/Intermedio (1-3 años)
4) Senior (3+ años)
5) Prefiero no decir
```

Save this — it influences the tone of the docs (more explanations for level 1-2, terser for 3-4).

### Q9 — Agent AI
```
👤 Pregunta 9 — ¿Con qué agente AI vas a trabajar?
(Si es vario, elegí el principal)

1) Claude Code (terminal o VS Code)
2) Claude Code Desktop (app Mac/Windows)
3) Cursor
4) Cline (extensión VS Code)
5) Antigravity (Google)
6) Aider (terminal)
7) Continue.dev
8) Varios / aún no decido
```

This determines which agent config file to generate:
- 1, 2 → `CLAUDE.md`
- 3 → `.cursorrules`
- 4 → `.clinerules`
- 5 → `agent.md`
- 6 → `.aider.conf.yml`
- 7 → `.continue/config.json`
- 8 → `CLAUDE.md` (default)

### Q10 — Country
```
👤 Pregunta 10 — ¿En qué país opera principalmente tu app?

1) Argentina  2) México  3) España  4) Colombia  5) Chile
6) Otro LATAM  7) USA/Canada  8) Europa (no España)  9) Global / múltiples
```

If user picked 2 or 3 in Q4 (selling), this affects payment processor recommendation:
- LATAM countries → mention Mercado Pago
- USA/Canada → Stripe
- Europe → Stripe / Lemon Squeezy (MoR)

---

## Stage 4 — Stack & starter (2 questions)

### Q11 — Stack knowledge
```
🛠️ Pregunta 11 — ¿Sabés qué tecnologías vas a usar?

1) Sí, ya sé qué stack quiero (lo cargo después en tech-context.md)
2) No, recomendame uno basado en mis respuestas
3) Decido más adelante con vos (mi agente AI)
```

### Q12 — Starter recommendation (path-specific)
Show recommendations BASED ON PATH_TYPE + Q3 (device):

**If PATH_TYPE = vercel AND Q3 = 1 (web)**:
```
🎁 Recomendaciones de starter para Web + Vercel:

1) Next.js + Supabase + Clerk (vanilla, fácil)
2) ixartz/SaaS-Boilerplate (GRATIS MIT, 7.2k⭐, con AGENTS.md pre-armado)
3) Kiranism/next-shadcn-dashboard-starter (GRATIS MIT, 6.5k⭐, dashboard B2B)
4) vercel/commerce (GRATIS MIT, e-commerce con Shopify)
5) onwidget/astrowind (GRATIS MIT, landing+blog en Astro)
6) Empiezo de cero (vos me guías al codear)
```

**If PATH_TYPE = vps AND Q3 = 1**:
```
🎁 Recomendaciones para path VPS comercial:

1) publiafy-stack-template (battle-tested patrón Publiafy — Node+Postgres+Redis+Traefik)
2) Empiezo de cero con docker-stack.yml básico (lo genero)
3) Otro (vos lo elegís después)
```

**If Q3 = 2 (móvil)**:
```
🎁 Recomendaciones para app móvil:

1) Ignite (Infinite Red — 19.8k⭐ MIT, RN+Expo+TS, sin auth/DB built-in)
2) obytes/react-native-template-obytes (4.2k⭐ MIT, RN+Expo minimal)
3) Empiezo de cero
```

**If Q3 = 4 (bot)**:
```
🎁 Recomendaciones para bots:

1) Telegram: bot-base/telegram-bot-template
2) Discord: discord.js boilerplate
3) WhatsApp: Baileys (⚠️ riesgo de ban — usar oficial WABA si serio)
4) Empiezo de cero
```

Save the choice.

---

## Stage 5 — Monetization (only if Q4 = 2 or 3)

### Q14 — Billing model
```
💰 Pregunta 14 — ¿Cómo vas a cobrar?

1) Suscripción mensual
2) Suscripción anual
3) Pago único
4) Freemium (gratis + features pagas)
5) Free todavía / decidir después
```

### Q15 — Payment processor
Filter recommendations based on Q10 (country):

If LATAM (Q10 = 1-6):
```
💰 Pregunta 15 — Procesador de pagos (LATAM-friendly):

1) Mercado Pago (LATAM nativo — fees ~4.99%)
2) Stripe (global, requiere setup más complejo en LATAM)
3) Lemon Squeezy (Merchant of Record — sin lidiar con impuestos)
4) No sé / recomendame Mercado Pago
```

Else:
```
💰 Pregunta 15 — Procesador de pagos:

1) Stripe (global, USA-friendly)
2) Lemon Squeezy (MoR)
3) Polar (open source)
4) PayPal
5) No sé
```

### Q16 — Currency
```
💰 Pregunta 16 — Moneda principal:

1) USD  2) MXN  3) ARS  4) EUR  5) Múltiples (multi-currency)
```

---

## Stage 6 — Plugins recommendation (only if Q9 = 1 or 2 — Claude Code)

### Q17 — Plugins
```
🔌 Pregunta 17 — ¿Querés que te recomiende plugins/skills para Claude Code?
(Validado junio 2026 — los más populares en el ecosistema)

1) ⭐ Top 3 esenciales:
   - Superpowers (obra/, 219k⭐) — TDD + spec-driven coding
   - Frontend Design (Anthropic oficial) — UI inteligente
   - Context7 (Upstash) — docs auto-actualizadas

2) ⭐⭐ Full vibecoding stack (top 3 + UI/UX Pro Max + claude-mem)

3) Solo info en CLAUDE.md (los instalo después)

4) No, gracias
```

---

## Stage 7 — Deep mode extras (only if mode = deep)

Ask these 8 edge case questions. Each on its own message:
- D1: ¿Múltiples idiomas? (No / Sí día 1 / Quizás después)
- D2: ¿Multi-tenant (datos separados por cliente)? (No / Sí / No sé qué significa)
- D3: ¿Tiempo real (chat, notif live)? (No / Sí / No sé)
- D4: ¿Archivos pesados (>10MB)? (No / Pocos chicos / Muchos pesados)
- D5: ¿Emails transaccionales? (No / Sí Resend / Volumen alto)
- D6: ¿IA generativa interna? (No / Chat LLM / RAG / Agentes / Generación imágenes)
- D7: ¿Testing automático? (Ninguno / Unit básico / Unit+integración / Completo E2E)
- D8: ¿Monitoreo errores? (No / Sí Sentry / Sí OSS)

---

## Stage 8 — Final setup (2 questions)

### Q18 — Git init
```
⚙️ Pregunta 18 — ¿Inicializar git automáticamente?

1) Sí, git init + primer commit
2) Ya tengo git acá
3) No, lo hago a mano
```

### Q19 — Agent file
```
⚙️ Pregunta 19 — ¿Creo el archivo de config de tu agente AI?

1) Sí, con instrucciones para leer docs/ al iniciar sesión (recomendado)
2) Sí pero vacío para que llene yo
3) No
```

---

## Stage 9 — Summary + confirmation

Mostrá un resumen con todas las respuestas:

```
📋 Resumen — esto voy a generar:

Tu proyecto:
  • Nombre: {Q1}
  • Path elegido: {PATH_TYPE} ({local-only / Vercel managed / VPS Contabo})
  • Plataforma: {Q3_label}
  • Propósito: {Q4_label}

Docs que voy a crear ({N} archivos):
  {list based on path}

{if VPS}: También configs Docker: docker-stack.yml, Dockerfile, backup.sh, etc.

Archivo agente AI: {AGENT_FILE} con instrucciones contextuales

¿Procedo a generar todo? (sí/no)
```

Esperá confirmación.

---

## Stage 10 — File generation

Si el user confirma, generá TODOS los archivos en este orden. Usá los templates en `references/`:

### Files to create (always)
- `docs/README.md` — index del harness
- `docs/active-context.md` — pre-poblar con entry del día de hoy mencionando el bootstrap
- `docs/product-context.md` — **PRE-POBLAR con Q2 (descripción del user)** + Q4 + Q5
- `docs/decisions.md` — pre-poblar con ADR-001 stub que documenta la elección de PATH_TYPE
- `docs/progress.md` — pre-poblar con época 0 + features de Q6
- `docs/known-issues.md` — vacío con header
- `docs/pendientes.md` — pre-poblar con Q6 features
- `docs/tech-context.md` — template con stack TBD si Q11=2 o Q11=3
- `docs/runbook.md` — template con primer procedure
- `docs/glossary.md` — vacío con header

### Path-specific files

**If PATH_TYPE = local**:
- `docs/local-setup.md` — copia de references/_local/local-setup.md

**If PATH_TYPE = vercel**:
- `docs/integrations.md` — Supabase + Clerk + Resend setup
- `docs/deploy-to-vercel.md` — paso a paso
- `docs/cloud-services-costs.md` — qué cuesta cuando crece

**If PATH_TYPE = vps**:
- `docs/security.md` — threat model + secrets (más profundo con compliance si Q7 marcó datos sensibles)
- `docs/integrations.md` — webhooks, OAuth
- `docs/system-patterns.md`
- `docs/lessons-learned.md`
- `docs/infrastructure.md` — topología real
- `docs/disaster-recovery.md` — backups + restore
- `docs/monitoring.md` — uptime + alertas
- `docs/costs.md` — pre-poblar con el tier elegido (Q4C)
- Y en la **raíz del proyecto** (no en docs/):
  - `docker-stack.yml` — copia de references/_vps_configs/docker-stack.yml.template, reemplazando {{PROJECT_NAME}} con Q1
  - `Dockerfile` — copia
  - `backup.sh` + `restore.sh` + `setup-secrets.sh` — copias
  - `.env.example` — copia
  - `.gitignore` — generar

### Placeholders to replace in TODOS los archivos generados

- `{{PROJECT_NAME}}` → Q1
- `{{YYYY-MM-DD}}` → fecha de hoy (usá `date -u +%Y-%m-%d` o equivalente)
- `{{OWNER}}` → si podés detectar git config user.name úsalo, sino pedile al user al inicio

### Agent file (CLAUDE.md / .cursorrules / etc.)

Según Q9, creá el archivo correspondiente en la raíz del proyecto con este contenido:

```markdown
# Contexto del Proyecto — {Q1}

Este proyecto usa el AI Agent Harness Template. Al inicio de cada sesión:

1. Lee `docs/README.md` para entender la estructura
2. Lee estos 4 docs prioritarios (te dan 80% del contexto):
   - `docs/active-context.md` — qué pasó la última sesión
   - `docs/product-context.md` — qué es este proyecto
   - `docs/progress.md` — qué features funcionan ya
   - `docs/known-issues.md` — qué bugs conocidos hay

[+ path-specific section]

## Path de infraestructura: {PATH_TYPE}
{description}

## Reglas para mantener los docs vivos
- Al final de cada sesión productiva: actualizá `active-context.md`
- Bugs → `known-issues.md`
- Decisiones arquitectónicas → nuevo ADR en `decisions.md`

[if Q17 = 1 or 2, add plugins section]
## Plugins recomendados (correr 1 sola vez)
\`/plugin install superpowers@claude-plugins-official\`
\`/plugin install frontend-design@claude-plugins-official\`
\`/reload-plugins\`
```

### Git init (if Q18 = 1)

Run via Bash tool:
```bash
git init
git add docs/ CLAUDE.md .gitignore [other root files]
git commit -m "chore: bootstrap AI Agent Harness (path: {PATH_TYPE})"
```

---

## Stage 11 — Final message

```
🎉 ¡Listo! Tu proyecto está preparado.

✅ Generé {N} archivos en docs/
✅ {Q18 result}
✅ Creé {AGENT_FILE} con tu contexto cargado
{if VPS}: ✅ Generé configs Docker en la raíz: docker-stack.yml, Dockerfile, scripts

📋 Próximos pasos:

{path-specific next steps — ver init-harness.sh para referencia}

🤖 Para arrancar a codear:
Decime "lee CLAUDE.md y proponé el primer paso" y te ayudo a empezar.
```

---

## State management

**Important**: as you collect answers, mantain mental state of:
- PATH_TYPE (local / vercel / vps)
- All Q1-Q19 answers
- Mode (quick / standard / deep)

Si el user dice "atrás" en cualquier punto, volvé a la pregunta anterior y permitile re-responderla.

Si dice "cancelar" o "stop", parate sin generar nada.

Si dice "no sé" en cualquier pregunta opcional, marcala como TODO y seguí.

---

## Cross-agent compatibility note

Esta skill funciona idealmente con Claude Code (plugin nativo). Para otros agentes:

- **Cursor**: el user puede pegar el contenido completo de este SKILL.md en su `.cursorrules` y pedirle a Cursor que "execute the wizard from these instructions"
- **Cline**: igual con `.clinerules`
- **Antigravity**: igual con `agent.md`
- **Continue.dev**: agregar como custom prompt

El user no necesita modificar nada — solo decir "ejecutá las instrucciones de SKILL.md" y el agente lo va a hacer.

---

## Failure modes — qué hacer si algo sale mal

- Si no podés acceder a `references/`: pedile al user que confirme que está usando el plugin instalado correctamente con `/plugin list`
- Si el user da respuestas no estándar a una pregunta de opción múltiple, interpretá best-effort y confirmá ("Entiendo que querés X, ¿correcto?")
- Si el git init falla porque ya existe `.git`, saltalo silenciosamente
- Si algún archivo de `references/` no existe, marcalo en el resumen final como "doc skipped" sin abortar
