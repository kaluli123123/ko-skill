# ko-skill

🌐 [English](README.md) | [中文](README.zh-CN.md) | [日本語](README.ja.md) | **한국어** | [Español](README.es.md) | [Français](README.fr.md) | [Português](README.pt.md)

특정 벤더나 제품에 종속되지 않는 독립적인 Agent Skill 모음입니다. 모든 skill은 공개 [Agent Skills 사양](https://agentskills.io)을 따르는 일반 텍스트 지침 파일입니다.

## 포함된 skill

- [`ko-bug`](skills/ko-bug/SKILL.md): 증거 우선 버그 진단 및 수정 프로토콜
- [`ko-github`](skills/ko-github/SKILL.md): 기능 개발 전에 재사용 가능한 GitHub 프로젝트와 라이브러리를 조사하는 프로토콜

## 설치

```bash
npx skills add kaluli123123/ko-skill@ko-bug
npx skills add kaluli123123/ko-skill@ko-github
```

`SKILL.md`는 일반 텍스트이므로 어떤 지침을 읽을 수 있는 AI에도 붙여 넣어 사용할 수 있습니다. 영어, 중국어, 일본어, 한국어 입력을 지원하며 사용자의 언어로 답변합니다.

## 주의사항

- skill은 특정 AI 제공업체나 제품에 종속되지 않습니다.
- 의료, 법률, 금융, 안전 문제의 판단을 대신하지 않습니다.
- 근거와 검증 결과를 만들어 내지 말고, 부족한 정보는 명확히 표시해야 합니다.
