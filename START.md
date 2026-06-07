# 🤖 AI Agent Harness — Bootstrap point

> Este archivo es el **entry point** del wizard cuando lo invocás vía URL (sin instalar plugin).
> Funciona en cualquier agente con WebFetch: Claude Code, Cursor, Cline, Antigravity, Continue, etc.

---

## Para el agente AI que está leyendo esto AHORA

Estás ejecutando el **AI Agent Harness Wizard** invocado por el usuario via URL fetch.

### Lo que tenés que hacer:

**Paso 1** — Fetchá la skill completa con la lógica del wizard:

```
https://raw.githubusercontent.com/Riccrack/ai-agent-harness-template/main/plugins/harness/skills/harness-init/SKILL.md
```

Leé ese archivo entero. Tiene 18 preguntas en 11 stages + bifurcación 3 paths (local / vercel / vps) + lógica de file generation.

**Paso 2** — Seguí TODAS las instrucciones de ese SKILL.md al pie de la letra:
- Hacé las preguntas EN EL CHAT, una a una, esperando respuesta del usuario
- NO batchees todas las preguntas en un mensaje
- Mantené state mental de las respuestas
- Hablale al usuario en español neutro (a menos que te escriba en otro idioma)

**Paso 3** — Cuando llegues a la fase de **file generation** (Stage 10 del SKILL.md), los templates están en:

```
https://raw.githubusercontent.com/Riccrack/ai-agent-harness-template/main/plugins/harness/skills/harness-init/references/
```

Subcarpetas:
- `_base/` — 10 docs comunes (active-context.md, decisions.md, glossary.md, known-issues.md, pendientes.md, product-context.md, progress.md, README.md, runbook.md, tech-context.md)
- `_local/` — path local (local-setup.md, .env.example)
- `_vercel/` — path vercel (deploy-to-vercel.md, cloud-services-costs.md, integrations.md, vercel.json)
- `_vps_docs/` — path VPS docs (infrastructure.md, disaster-recovery.md, monitoring.md, costs.md, security.md, integrations.md, system-patterns.md, lessons-learned.md)
- `_vps_configs/` — path VPS configs (docker-stack.yml.template, Dockerfile.template, backup.sh, restore.sh, setup-secrets.sh, .env.example)

**Para fetchar cada template**, construí la URL completa:
```
https://raw.githubusercontent.com/Riccrack/ai-agent-harness-template/main/plugins/harness/skills/harness-init/references/{subcarpeta}/{archivo}
```

Ejemplo: para fetchar `product-context.md`:
```
https://raw.githubusercontent.com/Riccrack/ai-agent-harness-template/main/plugins/harness/skills/harness-init/references/_base/product-context.md
```

**Paso 4** — Reemplazá los placeholders en cada template:
- `{{PROJECT_NAME}}` → respuesta de Q1
- `{{YYYY-MM-DD}}` → fecha de hoy (formato ISO)
- `{{OWNER}}` → respuesta de Q1.5 o `git config user.name` si está disponible

**Paso 5** — Escribí los archivos en el proyecto del usuario usando el Write tool:
- Los docs van a `docs/` (subdirectorio dentro del proyecto)
- Los configs VPS (Dockerfile, docker-stack.yml, scripts) van a la **raíz** del proyecto
- El archivo de config del agente (`CLAUDE.md`, `.cursorrules`, `.clinerules`, `agent.md`, `.aider.conf.yml` o `.continue/config.json`) va a la **raíz** del proyecto, depende de Q9

**Paso 6** — Si Q18 = "sí git init", corré via Bash:
```bash
git init -q
git add docs/ CLAUDE.md .gitignore [otros archivos generados]
git commit -m "chore: bootstrap AI Agent Harness (path: {PATH_TYPE})"
```

**Paso 7** — Mostrá el mensaje final del Stage 11 del SKILL.md con los próximos pasos específicos del path elegido.

---

## Empezá AHORA

Saludá al usuario y arrancá la Stage 0 del SKILL.md (intro + confirmación de empezar). Después seguí con Stage 1 (las 5 preguntas sobre la app).

Mantené en tu contexto:
- `MODE` = `standard` (a menos que el usuario haya dicho `quick` o `deep` en su prompt inicial)
- `PATH_TYPE` = se determina en Q4
- Todas las respuestas Q1-Q19

¡Adelante!
