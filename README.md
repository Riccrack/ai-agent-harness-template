# 🤖 AI Agent Harness Template

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Use this template](https://img.shields.io/badge/Use%20this-template-2ea44f?logo=github)](https://github.com/Riccrack/ai-agent-harness-template/generate)
[![Made for AI agents](https://img.shields.io/badge/built%20for-AI%20agents-blueviolet)](#)
[![Docs: 8-17 files](https://img.shields.io/badge/docs-8--17%20files-informational)](#-qué-vas-a-tener-al-terminar)
[![Paths: 3](https://img.shields.io/badge/paths-Local%20%7C%20Vercel%20%7C%20VPS-orange)](#-los-3-caminos-elegí-el-que-encaje)

> **Wizard interactivo que prepara tu proyecto para programar con IA — 3 caminos según si vas a vender o no.**

---

## 🆕 Novedades v2 (2026-06-05)

- 🌳 **3 caminos** según tu objetivo: Local-only / Vercel managed / VPS Contabo comercial
- 💰 **Budget tiers** explícitos en el camino VPS ($5 → $48/mes)
- ⚠️ **Warning automático** si elegís Vercel pero vas a vender (avisa que escala caro)
- 🐳 **Configs Docker generados** out-of-the-box para el camino VPS (docker-stack.yml, Traefik, backup scripts)
- 🤖 **Auto-creación** del archivo de config de tu agente AI (CLAUDE.md / .cursorrules / .clinerules / etc.)
- 📚 **4 docs nuevos** para path comercial: `infrastructure.md`, `disaster-recovery.md`, `monitoring.md`, `costs.md`

---

## 🤔 ¿Qué es esto y para qué sirve? (lee esto primero)

Imaginá que tenés una app y querés usar **agentes de inteligencia artificial** (como Claude, Cursor, Cline, GitHub Copilot) para que te ayuden a programar. El problema: cada vez que abrís una sesión nueva con el agente, **él no sabe nada de tu proyecto**. Tiene que volver a entender todo desde cero, gastando tiempo (y tu plata si pagás por API) buscando archivos al azar.

Este template te da **13 archivos de texto** (con extensión `.md`, que se llaman "markdown" — pero es solo texto plano que se ve lindo) que viven en una carpeta `docs/` dentro de tu proyecto. Cada archivo tiene un propósito específico: uno dice qué es tu app, otro qué bugs conocés, otro cómo deployar, etc.

Cuando arrancás una sesión con un agente de IA, el agente lee estos 13 archivos **primero**, y en 5 minutos ya entiende:
- Qué hace tu producto
- Qué tecnologías usás
- Qué decisiones tomaste y por qué
- Qué bugs hay pendientes
- Cómo deployar a producción

**Resultado**: el agente trabaja **mucho mejor**, comete menos errores, y vos no tenés que explicarle todo de nuevo cada sesión.

> 💡 También sirve para **vos** cuando volvés a un proyecto 6 meses después y no te acordás nada. Y para devs nuevos que se suman al equipo.

---

## 🎯 ¿Es para mí?

Sí, si...

- ✅ Programás con ayuda de un agente de IA (Claude Code, Cursor, Cline, etc.)
- ✅ Tu proyecto va a durar más de 1 semana
- ✅ Te cansa explicarle al agente las mismas cosas en cada sesión
- ✅ Querés que devs humanos también puedan entender tu proyecto rápido

No, si...

- ❌ Solo querés un script de 50 líneas
- ❌ El proyecto es desechable / experimento de 1 día

---

## 🌳 Los 3 caminos — elegí el que encaje

El wizard te pregunta primero **¿vas a vender esto?** y bifurca:

| Camino | Costo arranque | Costo crecimiento | Ideal para |
|---|---|---|---|
| 💻 **Local-only** | $0 | $0 (con limitaciones) | Aprender, dev tools, scripts personales |
| 🌐 **Vercel/Cloud** | $0 free tier | $70-300/mes apenas crece | Personal, portfolio, MVPs |
| 🚀 **VPS Contabo** | **$5/mes** (Cloud VPS 10) | $15 → $48 → $69+ según escalá | Comercial, vendible long-term |

### 💻 Camino Local

Tu app vive en tu computadora. SQLite en archivo local, sin reverse proxy, sin SSL.
Para compartir con alguien: ngrok / Tailscale / Cloudflare Tunnel.

### 🌐 Camino Vercel

`git push` y tu app está online en 30 segundos. Free tier generoso para arrancar pero **escala caro** cuando crecés (Vercel + Supabase + Clerk = ~$70/mes a los primeros 100 usuarios pagos).

### 🚀 Camino VPS Contabo (patrón Publiafy)

Self-hosted en VPS propio. Postgres + Redis + Traefik + tu app en Docker Swarm.
**Costo fijo predecible** desde $5/mes hasta $48-89/mes según escalá. Cero vendor lock-in.

Tiers de upgrade documentados (cuándo upgradear sólo cuando las métricas lo justifican):
- **Cloud VPS 10** ($5-7/mes) — arranque, 0-200 usuarios
- **Cloud VPS 20** ($7-9/mes) — validación, 200-800 usuarios
- **Cloud VPS 30** ($15-20/mes) — crecimiento, 800-2000 usuarios
- **VDS M** ($48/mes) — performance dedicada, 2000+ usuarios

---

## 📋 Antes de empezar — qué necesitás instalado

Tres herramientas básicas. Si no las tenés, instalalas (1 vez en tu vida):

### 1. Git — para clonar y guardar versiones del código

**¿Tengo Git?** Abrí una terminal (en Windows usá **Git Bash** o **PowerShell**, en Mac/Linux usá **Terminal**) y escribí:
```bash
git --version
```
Si te dice un número de versión (ej: `git version 2.42.0`) → ya lo tenés ✅

**Si no lo tenés**: descargalo de https://git-scm.com/downloads → instalador siguiente-siguiente-listo.

### 2. Node.js — para correr el comando `npx degit`

**¿Tengo Node?** En la terminal:
```bash
node --version
```
Si te dice un número (ej: `v20.10.0`) → ya lo tenés ✅

**Si no lo tenés**: descargalo de https://nodejs.org → bajá la versión **LTS** → instalador siguiente-siguiente-listo.

### 3. Una terminal con Bash

- **Mac/Linux**: ya viene incluida la app **Terminal**
- **Windows**: cuando instalás Git (paso 1) viene **Git Bash** incluido. Buscá "Git Bash" en el menú de Inicio.

---

## ⚡ Cómo instalar el template — 3 caminos (elegí UNO)

### 🌟 Camino 1 — El más fácil (wizard interactivo, recomendado)

Este camino te hace preguntas y arma todo solo.

**Paso 1**: abrí una terminal en la carpeta donde querés tu proyecto. Por ejemplo, si querés crear un proyecto nuevo llamado `mi-app`:

```bash
mkdir mi-app
cd mi-app
```

> 💬 ¿Qué hicimos? `mkdir mi-app` crea una carpeta nueva llamada `mi-app`. `cd mi-app` entra a esa carpeta.

**Paso 2**: descargá el template a una carpeta global en tu compu (solo se hace 1 vez en tu vida):

```bash
npx degit Riccrack/ai-agent-harness-template ~/.ai-harness
```

> 💬 ¿Qué hicimos? `npx degit` descarga este template sin guardar el historial de git (más rápido que `git clone`). Lo deja en `~/.ai-harness` (la `~` significa "tu carpeta de usuario": `/Users/tu-nombre` en Mac, `/home/tu-nombre` en Linux, `/c/Users/tu-nombre` en Windows Git Bash).

**Paso 3**: corré el wizard:

```bash
~/.ai-harness/init-harness.sh
```

> 💬 ¿Qué hicimos? Ejecutamos el script `init-harness.sh` que está en la carpeta global. Es un programa que te va a preguntar cosas.

El wizard te pregunta:
1. **Nombre del proyecto** → escribí lo que sea (ej: `MiApp`)
2. **Owner / autor** → tu nombre o nick (auto-detecta de git si lo configuraste)
3. **Idioma del contenido** → 1 (Español), 2 (English), 3 (Português)
4. **Stack principal** → ¿qué tecnología vas a usar?
   - 1) Node.js
   - 2) Python
   - 3) Ruby (Rails)
   - 4) Go
   - 5) Rust
   - 6) PHP (Laravel)
   - 7) Java / Kotlin (Spring)
   - 8) Otro / Decido después
5. **¿Inicializar git?** → `y` si querés que también haga `git init` automático, `n` si no

Listo. Tu carpeta `mi-app/` ahora tiene una subcarpeta `docs/` con 13 archivos llenos de contenido inicial específico para tu stack.

### 🛠️ Camino 2 — Solo descargar los archivos (sin wizard)

Si no querés el wizard y solo querés los 13 archivos vacíos:

```bash
cd mi-app
npx degit Riccrack/ai-agent-harness-template/harness-skeleton docs
```

> 💬 Esto deja los 13 archivos en `mi-app/docs/` con placeholders `{{PROJECT_NAME}}`, `{{YYYY-MM-DD}}`, `{{OWNER}}` que tenés que reemplazar a mano (o con buscar-y-reemplazar de tu editor).

### 🖱️ Camino 3 — Sin terminal, usando GitHub web

Si te marea la terminal:

1. Andá a https://github.com/Riccrack/ai-agent-harness-template
2. Click en el **botón verde "Use this template"** (arriba a la derecha)
3. Click en **"Create a new repository"**
4. Elegí un nombre, marcalo público o privado
5. Click "Create"
6. Listo — tenés un repo nuevo idéntico al template en tu cuenta. Clonalo a tu compu con `git clone <url-de-tu-repo-nuevo>` o descargalo como ZIP.

---

## 🤖 Configurar tu agente de IA para que use los docs

**Esto es lo más importante**: con el template instalado, ahora tenés que decirle a tu agente que **lea los docs al iniciar cada sesión**. Cada herramienta tiene una manera diferente.

Buscá tu herramienta abajo y seguí los pasos.

### 🟣 Claude Code (terminal / CLI)

Claude Code es el agente oficial de Anthropic que corrés desde la terminal.

**Paso 1**: si no lo tenés instalado, seguí https://docs.claude.com/en/docs/claude-code/quickstart

**Paso 2**: en la raíz de tu proyecto (al lado de la carpeta `docs/`), creá un archivo llamado `CLAUDE.md`. Podés crearlo así desde la terminal:

```bash
cd mi-app
touch CLAUDE.md
```

> 💬 `touch` crea un archivo vacío. En Windows con Git Bash funciona igual.

**Paso 3**: abrí `CLAUDE.md` en tu editor (VS Code, Notepad++, Sublime, lo que tengas) y pegá este contenido:

```markdown
# Contexto del Proyecto

Este proyecto usa el AI Agent Harness Template. Al inicio de cada sesión:

1. Leé `docs/README.md` para entender la estructura completa
2. Leé estos 4 docs prioritarios (te dan el 80% del contexto):
   - `docs/active-context.md` — qué pasó la última sesión
   - `docs/product-context.md` — qué es este proyecto
   - `docs/progress.md` — qué features funcionan ya
   - `docs/known-issues.md` — qué bugs conocidos hay
3. Según la tarea, leé también:
   - Para temas técnicos: `tech-context.md`, `system-patterns.md`, `decisions.md`
   - Para emergencias o deploy: `runbook.md`, `integrations.md`, `security.md`

## Reglas para mantener los docs vivos

- Al final de cada sesión productiva: actualizá `active-context.md` (entrada nueva al tope) y `progress.md`
- Si encontrás un bug → agregá entrada en `known-issues.md`
- Si un bug se repite por 2da vez → lección en `lessons-learned.md`
- Si tomamos una decisión arquitectónica → nuevo ADR en `decisions.md`
```

**Paso 4**: lanzá Claude Code desde la raíz del proyecto:

```bash
cd mi-app
claude
```

Claude Code lee `CLAUDE.md` **automáticamente**. La próxima vez que escribas un mensaje, ya tiene todo el contexto del proyecto.

### 🔵 Claude Code — extensión de Visual Studio Code

Si usás VS Code (editor de Microsoft, gratis):

**Paso 1**: abrí VS Code → andá al panel de **Extensions** (ícono de cuadrados a la izquierda, o `Ctrl+Shift+X`) → buscá **"Claude Code"** → click **Install**.

**Paso 2**: abrí tu proyecto en VS Code (`File → Open Folder`).

**Paso 3**: creá el archivo `CLAUDE.md` en la raíz del proyecto (clic derecho en el explorer → New File → nombralo `CLAUDE.md`) y pegale el mismo contenido del bloque de arriba.

**Paso 4**: abrí el panel de Claude Code (`Ctrl+Shift+P` → escribí "Claude Code" → enter). Empezá a chatear — la extensión usa el `CLAUDE.md` automáticamente.

> 💡 **Tip pro**: en `settings.json` de VS Code (`Ctrl+Shift+P` → "Preferences: Open User Settings (JSON)") agregá esto para que Claude no te pida permiso cada vez que quiere leer un doc:
> ```json
> "claude-code.autoApprove": ["Read", "Grep", "Glob"]
> ```

### 🖥️ Claude Code Desktop (app para Mac/Windows)

App nativa con interfaz visual:

**Paso 1**: descargá desde https://claude.ai/download → instalá.

**Paso 2**: abrí la app → `File → Open Folder` → seleccioná tu proyecto.

**Paso 3**: creá `CLAUDE.md` en la raíz del proyecto con el mismo contenido del bloque de Claude Code CLI.

**Paso 4**: chateá normal — la app lee el `CLAUDE.md` solo.

> 💡 **Bonus**: la app desktop soporta **slash commands** custom. Creá `.claude/commands/refresh.md` con:
> ```markdown
> Releé docs/active-context.md, docs/known-issues.md y docs/progress.md.
> Resumime el estado actual del proyecto en 5 puntos.
> ```
> Después en el chat escribís `/refresh` y Claude lo ejecuta.

### 🌌 Antigravity

Editor con AI integrada de Google:

**Paso 1**: instalá desde https://antigravity.google

**Paso 2**: abrí tu proyecto en Antigravity.

**Paso 3**: creá `agent.md` en la raíz del proyecto:

```markdown
# Agent Context

Project uses the AI Agent Harness Template. At session start, always read:

1. docs/README.md (estructura del harness)
2. docs/active-context.md (última sesión)
3. docs/product-context.md (qué es este proyecto)
4. docs/known-issues.md (bugs a evitar)

After every productive session, update docs/active-context.md and docs/progress.md.
```

**Paso 4**: si tu versión de Antigravity tiene memoria persistente, escribile en el chat:
```
@memory remember: this project uses AI Agent Harness — always read docs/ at session start
```

### 🟠 Cline (extensión de VS Code)

Cline inventó el patrón "Memory Bank" en el que se basa este template — por lo tanto es **100% compatible** nativamente.

**Paso 1**: en VS Code → Extensions → buscá **"Cline"** → Install.

**Paso 2**: en la raíz del proyecto, creá `.clinerules` (sí, empieza con punto y sin extensión):

```
# Cline rules — AI Agent Harness

Al iniciar sesión, leé en este orden:
1. docs/README.md
2. docs/active-context.md
3. docs/product-context.md
4. docs/known-issues.md

Este proyecto sigue el patrón AI Agent Harness (extensión del Memory Bank
de Cline). Los 13 docs en docs/ son la fuente de verdad del contexto.

Después de cada sesión productiva:
- Actualizá docs/active-context.md (entry nueva al tope)
- Actualizá docs/progress.md (si cambiaron features)
- Actualizá docs/known-issues.md (si aparecieron bugs)
```

**Paso 3**: en la barra lateral de Cline, click el ícono de **Memory Bank** → apuntalo a la carpeta `docs/`. Listo.

### 🎯 Cursor

Editor basado en VS Code con IA integrada:

**Paso 1**: instalá desde https://cursor.com

**Paso 2**: abrí tu proyecto en Cursor.

**Paso 3**: creá `.cursorrules` en la raíz del proyecto:

```
Project uses AI Agent Harness Template (13 docs in docs/).

At session start, ALWAYS read:
- docs/README.md (harness structure)
- docs/active-context.md (latest work)
- docs/product-context.md (what this is)
- docs/known-issues.md (bugs to avoid)

When the task involves architecture → also read docs/decisions.md and docs/system-patterns.md.
When debugging → also read docs/lessons-learned.md.
When deploying or troubleshooting → also read docs/runbook.md.

After productive sessions, update docs/active-context.md and docs/progress.md.
```

**Paso 4**: cerrá y volvé a abrir Cursor — las reglas se aplican automáticamente.

> 💡 **Versión moderna**: si tu Cursor pide usar `.cursor/rules/*.mdc` en lugar de `.cursorrules`, creá la carpeta `.cursor/rules/` y dentro un archivo `harness.mdc` con el mismo contenido pero con este header al inicio:
> ```yaml
> ---
> alwaysApply: true
> ---
> ```

### 🟢 Aider (terminal)

Agente de IA para terminal, open-source:

```bash
# Bootstrap del template
npx degit Riccrack/ai-agent-harness-template ~/.ai-harness
cd mi-app
~/.ai-harness/init-harness.sh

# Crear archivo de config persistente
cat > .aider.conf.yml << 'EOF'
read:
  - docs/README.md
  - docs/active-context.md
  - docs/product-context.md
  - docs/known-issues.md
  - docs/progress.md
EOF

# Lanzar Aider — auto-carga los 5 docs prioritarios
aider
```

### 🤖 Continue.dev (VS Code y JetBrains)

Extensión open-source con IA:

**Paso 1**: instalá Continue desde el marketplace de tu editor.

**Paso 2**: editá `.continue/config.json` (Continue lo crea solo cuando lo abrís) y agregá un context provider:

```json
{
  "contextProviders": [
    {
      "name": "folder",
      "params": { "folders": ["docs"] }
    }
  ]
}
```

**Paso 3**: en el chat de Continue, escribí `@docs` (o el nombre que le pusiste a la carpeta) cuando quieras que cargue todo el harness como contexto.

### 📦 Tabla resumen — qué archivo crear según tu herramienta

| Herramienta | Archivo a crear | ¿Se carga solo? |
|---|---|---|
| Claude Code (terminal) | `CLAUDE.md` | ✅ Sí |
| Claude Code (ext VS Code) | `CLAUDE.md` | ✅ Sí |
| Claude Code (app desktop) | `CLAUDE.md` + `.claude/commands/` | ✅ Sí |
| Antigravity | `agent.md` | ✅ Sí |
| Cline | `.clinerules` | ✅ Sí |
| Cursor | `.cursorrules` o `.cursor/rules/*.mdc` | ✅ Sí |
| Aider | `.aider.conf.yml` | ✅ Sí |
| Continue.dev | `.continue/config.json` + `@docs` manual | ⚠️ Disparo manual |

---

## 📚 ¿Qué vas a tener al terminar?

Una carpeta `docs/` con 13 archivos `.md`, organizados en 4 categorías visuales:

### 🟢 STATE — El presente vivo (lo que cambia seguido)
| Archivo | Para qué sirve |
|---|---|
| `active-context.md` | "Hoy hice esto, mañana sigo con aquello". Updates por sesión. |
| `progress.md` | Lista de features con check ✅ vs ⏳ pendiente. |
| `known-issues.md` | Bugs conocidos con su síntoma, causa y plan. |
| `pendientes.md` | Roadmap priorizado de qué hacer. |

### 🟡 CONTEXT — El entendimiento (qué es el proyecto)
| Archivo | Para qué sirve |
|---|---|
| `product-context.md` | Qué es la app, para quién, modelo de negocio. |
| `tech-context.md` | Stack técnico: lenguajes, frameworks, hosting. |
| `system-patterns.md` | Cómo está armada la arquitectura. |
| `glossary.md` | Vocabulario del dominio (ej: qué es un "thread" en tu app). |

### 🔵 KNOWLEDGE — La sabiduría meta (lo aprendido)
| Archivo | Para qué sirve |
|---|---|
| `decisions.md` | ADRs (decisiones arquitectónicas) con su contexto y alternativas. |
| `lessons-learned.md` | Patrones aprendidos por la mala. |

### 🟠 OPERATIONS — Cómo operamos (cómo se hacen las cosas)
| Archivo | Para qué sirve |
|---|---|
| `runbook.md` | Procedimientos paso a paso (deploy, rollback, etc.). |
| `integrations.md` | APIs externas que usás + sus rarezas. |
| `security.md` | Threat model + cómo manejás secrets. |

---

## 🔁 Workflow diario — cómo mantener vivos los docs

El template es inútil si no lo mantenés. Regla de oro: **5 minutos al final de cada sesión de trabajo**:

```
1. Abrí docs/active-context.md
2. Agregá una entrada al TOPE con la fecha de hoy
3. Escribí en 3-5 líneas: qué hiciste, qué pasó, qué sigue
4. Guardá + commit + listo
```

Y según lo que haya pasado:
- 🐛 ¿Apareció un bug? → entrada en `docs/known-issues.md`
- ✅ ¿Cerraste una feature? → línea en la tabla de `docs/progress.md`
- 🧭 ¿Tomaste una decisión grande (cambio de stack, nueva DB, etc.)? → ADR en `docs/decisions.md`

Si lo hacés religiosamente, en 6 meses vas a poder volver al proyecto y entender todo en 5 minutos.

---

## 🎬 Demo en 30 segundos

```bash
# 1. Crear proyecto nuevo
mkdir mi-saas && cd mi-saas

# 2. Descargar template (solo 1 vez en tu vida)
npx degit Riccrack/ai-agent-harness-template ~/.ai-harness

# 3. Correr wizard (te pregunta 5 cosas)
~/.ai-harness/init-harness.sh
# > Nombre: MiSaaS
# > Owner: Juan Pérez
# > Idioma: Español
# > Stack: Node.js
# > Git init: y

# 4. Crear CLAUDE.md con el contenido del bloque de arriba
# (o lo que corresponda a tu agente)

# 5. Abrir tu agente de IA y empezar a codear con todo el contexto cargado 🚀
```

---

## ❓ Preguntas frecuentes

### ¿Tengo que llenar TODOS los docs al inicio?
**No.** Llená 4 al principio (`product-context.md`, `tech-context.md`, `decisions.md` ADR-001, `active-context.md` día 0). Los demás se llenan cuando ocurren cosas (bug → `known-issues.md`, integración → `integrations.md`, etc.).

### ¿Qué pasa si no actualizo los docs?
A las 2 semanas el harness se queda obsoleto y el agente de IA empieza a proponer cambios basados en info vieja. Regla: **5 minutos al final de cada sesión**.

### ¿Esto sirve solo para proyectos con IA?
No. También sirve para vos cuando volvés en 6 meses y no te acordás nada. Y para devs humanos nuevos que se suman al equipo.

### ¿Puedo modificar la estructura?
Sí, es MIT — hacé lo que quieras. Pero **antes de borrar**: cada uno de los 13 docs tiene su razón de existir. Mirá la categoría (STATE/CONTEXT/KNOWLEDGE/OPERATIONS) y entendé qué cubre antes de cortarlo.

### ¿Y si mi proyecto es muy chico para tantos docs?
Empezá con los 4 mínimos. Los otros 9 quedan vacíos hasta que los necesites — no molestan a nadie.

### ¿Cómo archivo docs cuando se hacen gigantes?
Cuando `active-context.md` o `progress.md` superan **50 KB**, archivá las entradas viejas (>2 meses):
```bash
cd docs/
# Mover las entradas viejas a archive
# (manualmente con tu editor o con sed)
mv old-entries.md active-context-archive-2026-Q1.md
echo "Ver archivo histórico en active-context-archive-2026-Q1.md" >> active-context.md
```

### ¿Funciona en Windows nativo (sin WSL)?
Sí — usá **Git Bash** que viene incluido con Git for Windows. Todos los comandos `bash`, `mkdir`, `cd`, `cat`, `touch` funcionan ahí.

### Me da error `command not found: npx`
Te falta Node.js. Volvé a [Antes de empezar](#-antes-de-empezar--qué-necesitás-instalado) e instalalo.

### Me da error `permission denied` al correr `init-harness.sh`
Dale permisos de ejecución:
```bash
chmod +x ~/.ai-harness/init-harness.sh
```
Y volvé a correrlo.

### El wizard no me deja elegir stack — ¿qué hago?
Tu terminal puede no soportar `read -p`. Probá con bash explícito:
```bash
bash ~/.ai-harness/init-harness.sh
```

---

## 🎁 Ejemplo en producción

[Publiafy](https://publiafy.com) — SaaS multi-tenant de gestión de redes sociales con IA generativa — usa este harness con los 13 docs llenos (~250 KB de docs vivos). Es el caso de prueba real del template. El código fuente es privado, pero la app está abierta para registrarse.

---

## 🤝 Contribuir

¿Querés mejorar el template? PRs bienvenidos. Ideas:
- Skeletons nuevos (`api-contracts.md`, `frontend-architecture.md`, etc.)
- Variantes pre-armadas por framework (Next.js, Rails, Django, Spring)
- GitHub Action que valide que los docs estén actualizados
- Extensión de VS Code con snippets para entries comunes
- MCP server que exponga los docs a agentes via protocolo estándar

Ver [`CONTRIBUTING.md`](./CONTRIBUTING.md) para el detalle.

---

## 📜 Licencia

MIT — usalo donde quieras, comercial o no, sin pedir permiso.

---

<div align="center">

**Si te sirvió, dale ⭐ al repo arriba a la derecha.**

Hecho con ❤️ por [empareja2digitales](https://www.youtube.com/@empareja2digitales).

</div>
