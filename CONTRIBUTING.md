# Contribuir al AI Agent Harness Template

¡Gracias por querer mejorar el harness! Este doc te dice cómo.

## Filosofía del proyecto

- **Mínimo viable**: cada skeleton debe ser usable día 1 sin llenar todas las secciones.
- **Idioma agnóstico**: nombres de archivos en inglés (kebab-case), contenido en cualquier idioma.
- **Agente-friendly**: cada doc tiene frontmatter con `> **Audiencia**`, `> **Propósito**`, `> **Cuándo actualizar**`. NO romper esa convención.
- **No invención**: si una sección no aplica a la mayoría de proyectos, NO va al skeleton.

## Cómo contribuir

### 🐛 Reportar bug
1. Verificá que no exista [un issue similar](../../issues?q=is%3Aissue)
2. Abrí un nuevo issue con el template **🐛 Bug report**

### 💡 Sugerir feature
1. Abrí un issue **💡 Feature request**
2. Discutí antes de codear si el cambio es grande

### 📝 Proponer skeleton nuevo
1. Abrí un issue **📝 Propuesta de nuevo skeleton doc**
2. Justificá por qué los 13 actuales no alcanzan
3. Si hay 👍 de los maintainers, podés mandar PR

### 🔧 Mandar PR

```bash
# 1. Fork + clone
git clone https://github.com/TU-USUARIO/ai-agent-harness-template.git
cd ai-agent-harness-template

# 2. Branch nueva
git checkout -b feature/mi-mejora

# 3. Probá el script localmente
mkdir test-project && cd test-project
../init-harness.sh
# Verificá que los 13 docs quedan bien

# 4. Commit + push + PR
git commit -am "feat: descripción breve"
git push origin feature/mi-mejora
```

## Convenciones de commits

Usamos [Conventional Commits](https://www.conventionalcommits.org/):
- `feat: ...` — feature nueva
- `fix: ...` — bug fix
- `docs: ...` — solo cambia documentación
- `refactor: ...` — cambio de código sin cambio de comportamiento
- `chore: ...` — tooling, deps, etc.

## Estilo de skeletons

Cada `harness-skeleton/*.md` debe:

1. **Empezar con título** + emoji estándar de su categoría:
   ```markdown
   # 🎯 active-context.md — ...
   ```

2. **Tener frontmatter** con los 3 campos obligatorios:
   ```markdown
   > **Última actualización**: {{YYYY-MM-DD}}
   > **Audiencia**: ...
   > **Propósito**: ...
   > **Cuándo actualizar**: ...
   ```

3. **Usar placeholders** estándar:
   - `{{PROJECT_NAME}}` → nombre del proyecto
   - `{{YYYY-MM-DD}}` → fecha actual
   - `{{OWNER}}` → owner del proyecto

4. **Incluir 1-2 secciones de ejemplo** comentadas (`<!-- ejemplo: ... -->`) para guiar al usuario.

5. **NO incluir info hardcoded** de Publiafy ni de ningún proyecto específico.

## Testing del wizard

```bash
# Test básico
mkdir /tmp/test-harness && cd /tmp/test-harness
~/ai-agent-harness-template/init-harness.sh "TestApp"
ls docs/  # Debería listar los 13 .md

# Test con stack específico
mkdir /tmp/test-node && cd /tmp/test-node
~/ai-agent-harness-template/init-harness.sh
# Elegí Node.js cuando pregunte
grep -q "Node.js + Express" docs/tech-context.md && echo "OK"
```

## Maintainers

- [@Riccrack](https://github.com/Riccrack) — creador y mantenedor principal

## Licencia

Al contribuir, aceptás que tu código se publique bajo MIT (la misma licencia del repo).
