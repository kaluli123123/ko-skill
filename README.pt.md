# ko-skill

🌐 [English](README.md) | [中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | **Português**

Uma coleção de Agent Skills independentes e neutras em relação a fornecedores. São arquivos de instruções em texto simples que seguem a especificação aberta de [Agent Skills](https://agentskills.io).

## Skills incluídas

- [`ko-bug`](skills/ko-bug/SKILL.md): protocolo de diagnóstico e correção de bugs baseado em evidências
- [`ko-github`](skills/ko-github/SKILL.md): pesquisa de projetos e bibliotecas reutilizáveis do GitHub antes de construir recursos importantes
- [`ko-github-issues`](skills/ko-github-issues/SKILL.md): entrega de um bug reproduzível como Issue e PR do GitHub com controles de propriedade e verificação

## Instalação

```bash
npx skills add kaluli123123/ko-skill@ko-bug
npx skills add kaluli123123/ko-skill@ko-github
npx skills add kaluli123123/ko-skill@ko-github-issues
```

Cada `SKILL.md` é texto simples e pode ser usado com qualquer IA capaz de ler instruções. São aceitas entradas em inglês, chinês, japonês, coreano, espanhol, francês e português; responda no idioma do usuário.

## Observações importantes

- As skills não dependem de nenhum fornecedor ou produto de IA.
- Não substituem profissionais em questões médicas, jurídicas, financeiras ou de segurança.
- Não invente evidências nem resultados de verificação; indique claramente as informações ausentes.
