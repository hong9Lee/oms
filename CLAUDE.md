# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## [MANDATORY] 세션 시작 시 역할 선택 (최우선 실행)

**세션의 첫 번째 사용자 메시지를 받으면, 어떤 내용이든 상관없이 반드시 아래를 먼저 수행하라:**

1. 사용자에게 역할을 선택하도록 질문한다 (AskUserQuestion 도구 사용)
2. 사용자가 역할을 선택하면 해당 가이드 파일을 즉시 읽는다 (Read 도구 사용)
3. 가이드 파일의 [MANDATORY] 섹션을 실행한다
4. 그 후에 사용자의 원래 요청을 처리한다

| 역할 | 설명 | 가이드 파일 |
|------|------|------------|
| **TPM** | 기술 설계 및 아키텍처 (개발자 출신 PM) | `.claude/role/tpm/README.md` |
| **Backend** | Java/Spring Boot 마이크로서비스 개발 | `.claude/role/backend/README.md` |

**이 단계를 건너뛰지 마라. 사용자가 "hi"라고만 입력해도 역할 선택을 먼저 수행하라.**

---

## Repository Overview

OMS (Order Management System) MSA. 주문 이행 라이프사이클을 처리하는 2개의 마이크로서비스로 구성된다.

> **용어 동의어:** "oms 프로젝트", "root", "루트", "클로드 프로젝트", "부모 프로젝트" → 모두 이 저장소(리포지토리 루트)를 의미한다.

| 서비스 | 역할 |
|--------|------|
| `oms-core/` | 주문 엔진 (Single Source of Truth) |
| `oms-plan/` | 외부 API 게이트웨이 |

각 서비스에 `CLAUDE.md`와 `.claude/ai-context/` 폴더가 있다. 로드 시점은 역할별 README에서 관리한다.

---

## [MANDATORY] Agent 행동 규칙 — PROHIBITED

**사용자가 명시적으로 요청한 작업만 수행한다. 아래 금지 목록을 최우선으로 따른다.**

### ❌ 범위 확장 금지

- ❌ **컨벤션/규칙 파일 자동 수정 금지** — SKILL.md, CLAUDE.md, role README, deploy-guide 등은 사용자가 명시적으로 요청해야만 수정. 단, PR 요청 시 도메인 지식 파일은 자동 동기화 (`/develop` AI_CONTEXT_SYNC 참조)
- ❌ **질문/의견 요청을 수정 지시로 해석 금지** — "어떻게 생각해?", "방향이 맞아?" 등은 의견만 답하라
- ❌ **동의를 작업 승인으로 확대 해석 금지** — "좋아", "그걸로 가자"는 수정/커밋/push 승인이 아니다
- ❌ **이전 메시지의 요청을 이후 메시지에 자동 적용 금지** — 각 메시지는 독립적이다

### ❌ git 작업 금지

- ❌ **사용자 키워드 없이 git 작업 금지** — "커밋", "push"/"푸쉬", "PR" 키워드가 해당 메시지에 있어야만 수행
- ❌ **`gh pr merge` 절대 금지** — 엔지니어가 직접 머지한다
- ❌ **`main` 브랜치 직접 커밋/push 금지** — Hook으로 강제 차단됨 (`.claude/hooks/protect-git.sh`)

> git 트리거 키워드, 브랜치 규칙, 상세는 `/develop` 스킬 GIT_RULES 참조
