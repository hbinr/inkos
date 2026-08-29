# AGENTS.md

InkOS（v1.8.0）—— 故事创作 AI Agent 系统（长/短篇小说、剧本、互动影游、多语言翻译）。TypeScript + pnpm monorepo，AGPL-3.0。本仓库是 fork，二次开发统一在 `dev` 分支进行。

## Project

- 技术栈：TypeScript（ESM，`"type": "module"`）、pnpm workspace；要求 node >= 22、pnpm >= 9
- 三个包：`packages/core`（agent 内核/harness）、`packages/cli`（CLI + TUI）、`packages/studio`（React + Vite web 工作台 + Hono API server）
- 入口：CLI 为 `packages/cli/src/index.ts`（构建后 bin 名 `inkos`）；Studio 前端 `packages/studio/src/main.tsx`、API server `packages/studio/src/api/index.ts`（dev 端口：前端 4567 / API 4569）

## Commands

- 安装：`pnpm install`（CI 用 `pnpm install --frozen-lockfile`）
- 构建：`pnpm build`（= `pnpm -r build`）
- 测试：`pnpm test`（vitest）；Studio E2E：`pnpm --filter @actalk/inkos-studio test:e2e`（playwright）
- 类型检查：`pnpm typecheck`
- 开发：`pnpm dev`（core/cli 为 `tsc --watch`；Studio 需 `pnpm --filter @actalk/inkos-studio dev`）
- CI（`.github/workflows/ci.yml`）实际执行：`pnpm build` → `pnpm test`

## Architecture

- `packages/core` — pi-agent 生产 harness：`agent/` `agents/`（智能体）、`pipeline/`（各作品类型管线）、`state/`（故事状态）、`retrieval/`、`llm/`（模型接入与路由）、`skills/`（15 个内置 `SKILL.md`）、`interactive-film/`、`translation/`、`materials/`
- `packages/cli` — `program.ts`（命令注册）、`commands/`、`tui/`、`project-bootstrap.ts`、`book-backup.ts`
- `packages/studio` — React 前端 `components/` `pages/` `hooks/` `store/` + Hono API `api/`；作品数据模型集中在 `app-state.ts`

## 分支工作流（重要）

- `origin` = 自己的仓库（`hbinr/inkos`，推送目标）；`upstream` = 原项目 `Narcooo/inkos`（只读）
- `main` — 仅本地同步分支，跟踪 `upstream/master`，**永不推送 origin**（推送也没有 upstream，会报错）
- `dev` — 日常开发分支，推送到 `origin/dev`；默认工作分支
- `master` — 保留不动（origin 默认分支），不在其上开发
- 同步上游最新代码：运行 `./scripts/sync-upstream.sh`（拉 upstream → 更新 main → 合并进 dev → 推送 dev）；或手动：`git checkout main && git merge --ff-only upstream/master && git checkout dev && git merge main && git push`

## Conventions

- 测试用 vitest，测试文件位于各包 `__tests__/` 或 `*.test.ts`；改动涉及核心逻辑时补充测试
- 提交前必须通过 `pnpm typecheck` 与 `pnpm build`；CI 只跑 build + test
- 无 eslint/prettier 配置，遵循既有代码风格（TS ESM、双引号、4 空格缩进为主）
- `scripts/` 下为发布辅助脚本（`prepare-package-for-publish.mjs` 等），发版由 `release.yml` 处理，本地不要直接改各包版本号
- 文档与提示词以简体中文为主（README/CHANGELOG 三语并存）

## Notes

- （留空，供后续补充）
