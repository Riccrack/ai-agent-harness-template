# 🤖 harness — Plugin del AI Agent Harness para Claude Code

Wizard interactivo que prepara tu proyecto para vibecoding **sin terminal**. Te hago 18 preguntas en el chat y genero los docs + configs por vos.

---

## ⚡ Instalación (1 sola vez)

### Para Claude Code (CLI, VS Code extension, o Desktop)

En el chat de Claude Code, escribí:

```
/plugin marketplace add Riccrack/ai-agent-harness-template
/plugin install harness@ai-agent-harness-template
/reload-plugins
```

¡Listo! Ahora tenés disponibles los slash commands `/harness-init` y `/harness-upgrade`.

### Para otros agentes (Cursor, Cline, Antigravity, Continue.dev)

Mirá la sección "Cross-agent setup" más abajo.

---

## 🎯 Uso — empezar un proyecto nuevo

1. Abrí Claude Code en la carpeta de tu proyecto nuevo (vacía o existente)
2. En el chat escribí:
   ```
   /harness-init
   ```
3. Yo te voy a hacer 18 preguntas conversacionales. Respondé en lenguaje natural.
4. Al final genero todo automáticamente:
   - `docs/` con 8-17 markdown skeletons (según el path elegido)
   - `CLAUDE.md` con tu contexto cargado
   - Configs Docker si elegiste VPS
   - `git init` + primer commit si pediste

### Modos

| Comando | Modo | Preguntas | Tiempo |
|---|---|---|---|
| `/harness-init` | Standard | 18 | ~8 min |
| `/harness-init quick` | Quick | 5 esenciales | ~2 min |
| `/harness-init deep` | Deep | 18 + edge cases | ~20 min |

---

## 🔄 Upgrade entre paths

Si tu proyecto empezó personal y ahora querés vender (o viceversa):

```
/harness-upgrade to=vps      # migrar a path VPS comercial
/harness-upgrade to=vercel   # migrar a Vercel
```

No destruyo nada de lo que ya tenés — solo agrego lo necesario para el path nuevo + un ADR documentando la migración.

---

## 🌐 Cross-agent setup

El plugin es nativo de Claude Code, pero la lógica del wizard funciona en CUALQUIER agente que soporte markdown rules. Los pasos:

### 🎯 Cursor

1. Clonar este repo en algún lugar:
   ```bash
   git clone https://github.com/Riccrack/ai-agent-harness-template ~/.ai-harness
   ```
2. En tu proyecto, crear `.cursorrules` con:
   ```
   When the user invokes /harness-init or asks to "set up the harness",
   read and execute the instructions in:
   ~/.ai-harness/plugins/harness/skills/harness-init/SKILL.md
   
   Follow all instructions in that file. Use the templates in:
   ~/.ai-harness/plugins/harness/skills/harness-init/references/
   ```
3. En el chat de Cursor: "Ejecutá el wizard del harness siguiendo las instrucciones de SKILL.md"

### 🟠 Cline

1. Mismo clone como arriba
2. Crear `.clinerules` con el mismo contenido
3. En el chat de Cline: "/harness-init" o "configurá el harness"

### 🌌 Antigravity

1. Mismo clone
2. Crear `agent.md` con el mismo contenido
3. En el chat de Antigravity: "Ejecutá las instrucciones del wizard del harness en SKILL.md"

### 🤖 Continue.dev

1. Mismo clone
2. Agregar como Custom Prompt en `.continue/config.json`:
   ```json
   {
     "customPrompts": [{
       "name": "harness-init",
       "prompt": "Read and execute ~/.ai-harness/plugins/harness/skills/harness-init/SKILL.md"
     }]
   }
   ```
3. En Continue: tipear `/harness-init`

### 🟢 Aider

```bash
aider --read ~/.ai-harness/plugins/harness/skills/harness-init/SKILL.md
# Después en Aider: "Ejecutá el wizard del harness siguiendo las instrucciones"
```

---

## 📂 Estructura del plugin

```
harness/
├── .claude-plugin/
│   └── plugin.json                # metadata del plugin
├── commands/
│   ├── harness-init.md            # /harness-init slash command
│   └── harness-upgrade.md         # /harness-upgrade slash command
├── skills/
│   └── harness-init/
│       ├── SKILL.md               # lógica del wizard (las 18 preguntas)
│       └── references/            # templates de docs y configs
│           ├── _base/             # 10 docs comunes a todos los paths
│           ├── _local/            # docs path local-only
│           ├── _vercel/           # docs path Vercel
│           ├── _vps_docs/         # docs path VPS Contabo (8 archivos)
│           └── _vps_configs/      # configs Docker (stack.yml, Dockerfile, backup.sh, etc.)
└── README.md (este archivo)
```

---

## 🐛 Troubleshooting

### El slash command `/harness-init` no aparece
- Confirmá install: en Claude Code, tipeá `/plugin list` — debería listar `harness`
- Si no aparece: `/plugin install harness@ai-agent-harness-template`
- Forzar reload: `/reload-plugins`

### Claude no me hace preguntas, me genera todo de una
- Reiniciá la sesión y volvé a invocar `/harness-init`
- Si persiste: reportá issue en https://github.com/Riccrack/ai-agent-harness-template/issues

### El plugin generó docs en el lugar equivocado
- Claude trabaja en el directorio actual del proyecto
- Asegurate de tener Claude Code abierto en la carpeta correcta (no en tu home)

---

## 📜 Licencia

MIT — usá esto en cualquier proyecto, comercial o no.
