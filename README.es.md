# ko-skill

🌐 [English](README.md) | [中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | **Español** | [Français](README.fr.md) | [Português](README.pt.md)

Una colección de Agent Skills independientes y neutrales respecto a proveedores. Son archivos de instrucciones en texto plano que siguen la especificación abierta de [Agent Skills](https://agentskills.io).

## Skills incluidos

- [`ko-bug`](skills/ko-bug/SKILL.md): protocolo de diagnóstico y corrección de errores basado en evidencias
- [`ko-github`](skills/ko-github/SKILL.md): investigación de proyectos y bibliotecas reutilizables de GitHub antes de construir funciones importantes

## Instalación

```bash
npx skills add kaluli123123/ko-skill@ko-bug
npx skills add kaluli123123/ko-skill@ko-github
```

Cada `SKILL.md` es texto plano y puede usarse con cualquier IA capaz de leer instrucciones. Se admiten entradas en inglés, chino, japonés y coreano; responde en el idioma del usuario.

## Notas importantes

- Las skills no dependen de ningún proveedor o producto de IA.
- No sustituyen el criterio profesional en asuntos médicos, legales, financieros o de seguridad.
- No inventes evidencias ni resultados de verificación; marca claramente la información que falta.
