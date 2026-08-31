# ko-skill

🌐 [English](README.md) | [中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | **Français** | [Português](README.pt.md)

Une collection d’Agent Skills indépendants et neutres vis-à-vis des fournisseurs. Ce sont des fichiers d’instructions en texte brut conformes à la spécification ouverte [Agent Skills](https://agentskills.io).

## Skills inclus

- [`ko-bug`](skills/ko-bug/SKILL.md) : protocole de diagnostic et de correction des bugs fondé sur les preuves
- [`ko-github`](skills/ko-github/SKILL.md) : recherche de projets et bibliothèques GitHub réutilisables avant de construire une fonctionnalité importante

## Installation

```bash
npx skills add kaluli123123/ko-skill@ko-bug
npx skills add kaluli123123/ko-skill@ko-github
```

Chaque `SKILL.md` est un fichier texte utilisable avec toute IA capable de lire des instructions. Les entrées en anglais, chinois, japonais et coréen sont prises en charge ; réponds dans la langue de l’utilisateur.

## Notes importantes

- Les skills ne dépendent d’aucun fournisseur ou produit d’IA.
- Ils ne remplacent pas l’avis de professionnels pour les questions médicales, juridiques, financières ou de sécurité.
- N’invente pas de preuves ni de résultats de vérification ; indique clairement les informations manquantes.
