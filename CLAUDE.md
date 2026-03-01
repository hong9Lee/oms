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

| 서비스 | 역할 |
|--------|------|
| `oms-core/` | 주문 엔진 (Single Source of Truth) |
| `oms-plan/` | 외부 API 게이트웨이 |

각 서비스에 `CLAUDE.md`와 `.claude/ai-context/` 폴더가 있다. 로드 시점은 역할별 README에서 관리한다.

---

## [MANDATORY] Agent 행동 규칙

명시적으로 요청된 작업만 수행한다. 요청 범위를 임의로 확장하지 않는다.

### ❌ git 작업 금지 (사용자 명시 없이 절대 수행 불가)

- ❌ **`git commit` 금지** — 사용자가 해당 메시지에서 "커밋"이라고 말하지 않으면 실행하지 마라
- ❌ **`git push` 금지** — 사용자가 해당 메시지에서 "push" 또는 "푸쉬"라고 말하지 않으면 실행하지 마라
- ❌ **`gh pr create` 금지** — 사용자가 해당 메시지에서 "PR"이라고 말하지 않으면 실행하지 마라
- ❌ **`gh pr merge` 금지** — 어떤 상황에서도 Agent가 실행하지 마라. 엔지니어가 직접 머지한다.
- ❌ **`main` 브랜치에 직접 커밋/push 금지** — 모든 변경은 feature 브랜치 → PR로 반영한다.

**코드 수정 = 파일 변경만 의미한다. git 작업은 암묵적으로 포함되지 않는다.**
"방향이 맞다", "이걸로 가자" 등의 동의는 **코드 수정 승인**이지, git 작업 승인이 아니다.
git 작업은 반드시 **해당 메시지에서** 별도 키워드로 명시해야 수행한다.

> 트리거 키워드와 상세 규칙은 `/develop` 스킬 GIT_RULES 참조

---

## 참조

| 상황 | 참조 |
|------|------|
| 역할별 가이드 | `.claude/role/{role}/README.md` |
| 서비스별 상세 | `{서비스}/CLAUDE.md` |
| 도메인 용어 | `.claude/ai-context/domain-glossary.md` |
| PR 작성 | `.claude/ai-context/pr-template.md` |
| 개발 컨벤션 | `/develop` 스킬 |
| 배포 절차 | `/deploy` 스킬 |
