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

OMS (Order Management System) MSA - 2개의 마이크로서비스 레포지토리입니다. 향후 주문부터 배송까지 전체 주문 이행 라이프사이클을 처리하게 됩니다.

## 공통 AI 컨텍스트

| 문서 | 설명 |
|------|------|
| [domain-glossary.md](.claude/ai-context/domain-glossary.md) | OMS MSA 핵심 도메인 용어집 (DeliveryPolicy, Courier, 1P/3P 등) |
| [pr-template.md](.claude/ai-context/pr-template.md) | PR 작성 템플릿 |

## MSA 서비스 디렉토리

```
oms-msa/
├── oms-plan/               # 외부 API 게이트웨이
├── oms-core/               # 주문 엔진 (Single Source of Truth)
```

각 서비스에는 상세 가이드가 포함된 `CLAUDE.md` 파일이 있습니다.

## 서비스별 AI 컨텍스트

각 서비스의 `.claude/ai-context/` 폴더에는 다음 문서들이 있습니다:

| 파일 | 설명 | 로드 시점 |
|------|------|----------|
| `domain-overview.md` | 도메인 개요, 핵심 개념 | 즉시 |
| `data-model.md` | 데이터 구조, 엔티티 관계 | 즉시 |
| `api-spec.json` | API 명세 | 질문 시 |
| `kafka-spec.json` | Kafka 토픽, 이벤트 스키마 | 질문 시 |
| `external-integration.md` | 외부 시스템 연동 | 질문 시 |
| `development-guide.md` | 개발 가이드 | Backend/Frontend 역할 시 |
| `deploy-guide.md` | 배포 절차 | 배포 요청 시 |

---

## [MANDATORY] Agent 행동 규칙

**사용자가 명시적으로 요청한 작업만 수행하라. 요청 범위를 임의로 확장하지 마라.**

### main 브랜치 보호

main에서 직접 커밋/push 절대 금지. 모든 변경은 feature 브랜치 → PR로만 반영한다.
PR 머지(`gh pr merge` 포함)는 Agent가 수행하지 않는다. 사람이 GitHub UI에서만 수행한다.

### 작업별 트리거

| 작업 | 트리거 | 비고 |
|------|--------|------|
| 커밋 | "커밋해" | 명시적 요청 전까지 금지 |
| push | "push해" | 커밋은 선행 작업으로 자동 포함 |
| PR 생성 | "PR 올려" | 명시적 요청 전까지 금지 |
| 브랜치 + 작업 | "작업해봐" | 브랜치 생성 + 코드 수정까지만 |
| 배포 | "배포해" | `/deploy` 스킬 참조 |

---

## 참조

| 상황 | 참조 |
|------|------|
| 역할별 가이드 | `.claude/role/{role}/README.md` |
| 서비스별 상세 | `{서비스}/CLAUDE.md` |
| 도메인 용어 | `.claude/ai-context/domain-glossary.md` |
| 개발 컨벤션 | `/develop` 스킬 |
| 배포 절차 | `/deploy` 스킬 |
