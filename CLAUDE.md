# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

OMS (Order Management System) MSA - 2개의 마이크로서비스 레포지토리입니다. 향후 주문부터 배송까지 전체 주문 이행 라이프사이클을 처리하게 됩니다.

## 역할 기반 작업 가이드

> **Claude는 사용자 역할에 따라 다른 컨텍스트를 로드합니다.**
>
> 세션 시작 시 역할을 선택하면 해당 역할에 맞는 상세 가이드가 제공됩니다.

| 역할 | 설명 | 가이드 파일 |
|------|------|------------|
| **TPM** | 기술 설계 및 아키텍처 (개발자 출신 PM) | [.claude/role/tpm/README.md](.claude/role/tpm/README.md) |
| **Backend** | Java/Spring Boot 마이크로서비스 개발 | [.claude/role/backend/README.md](.claude/role/backend/README.md) |

## 공통 AI 컨텍스트

| 문서 | 설명 |
|------|------|
| [domain-glossary.md](.claude/ai-context/domain-glossary.md) | OMS MSA 핵심 도메인 용어집 (OrderType, TemperatureType 등) |
| [pr-template.md](.claude/ai-context/pr-template.md) | PR 작성 템플릿 |

## MSA 서비스 디렉토리

```
oms-msa/
├── oms-order-operation/               # 외부 API 게이트웨이
├── soms/                              # 주문 엔진 (Single Source of Truth)
└── oms-tools/                         # 배포 도구
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

## 🚨 배포 준비 필수 규칙 (MANDATORY)

**⚠️ 배포 요청을 받으면 반드시 해당 MSA 프로젝트의 CLAUDE.md 파일을 먼저 읽고 진행하세요.**

### 배포 준비 6단계 (전체 필수 실행)

| 단계 | 작업 | 설명 |
|------|------|------|
| **1** | 현재 버전 및 변경 내용 확인 | `ServerPropertiesController.java`에서 현재 버전 확인, 이전 태그 이후 변경 내용 분석 |
| **2** | 배포 제목 작성 | 변경 내용을 분석하여 배포 제목을 AI가 직접 작성 |
| **3** | 버전 업데이트 | `ServerPropertiesController.java`의 버전을 +1 증가 |
| **4** | master 브랜치에 커밋 & push | 버전 변경 사항을 커밋하고 push |
| **5** | 태그 생성 & push | 새 버전으로 Git 태그 생성 및 push |
| **6** | 운영배포 요청서 작성 | oms-tools 스크립트로 Jira 서비스데스크 폼 자동 입력 |

### 배포 준비 실행 명령어

```bash
# 1. 현재 버전 확인
cat {서비스경로}/src/main/java/com/kurly/{서비스}/core/common/ServerPropertiesController.java | grep "return"

# 2. 이전 태그 이후 변경 내용 확인
cd {서비스경로}
git log v{현재버전}..HEAD --oneline

# 3. 버전 업데이트 (Edit 도구 사용)
# ServerPropertiesController.java에서 버전 문자열 수정

# 4. 커밋 & push
git add src/main/java/com/kurly/{서비스}/core/common/ServerPropertiesController.java
git commit -m "v{새버전}"
git push origin master

# 5. 태그 생성 & push
git tag v{새버전}
git push origin v{새버전}

# 6. 운영배포 요청서 작성
cd /Users/mk-mac-348/Desktop/oms/repo/oms-msa/oms-tools
source venv/bin/activate
python3 auto-fill-from-pr.py {PR_URL} -d v{새버전} -r v{이전버전} -t "{배포제목}"
```

### 버전 규칙
- 형식: `v{major}.{minor}.{patch}` (예: v3.3.17)
- 일반 배포: patch 버전 +1 (3.3.17 → 3.3.18)
- 주요 기능 추가: minor 버전 +1 (3.3.x → 3.4.0)

### 배포 준비 전 필수 확인사항

| 필수 정보 | 설명 | 예시                                            |
|----------|------|-----------------------------------------------|
| **프로젝트** | 어떤 서비스를 배포할지 | oms-plan, oms-core 등                          |
| **PR URL** | 배포 기준이 되는 PR 링크 | https://github.com/hong9Lee/oms-plan/pull/123 |

**⚠️ PR 링크가 없으면 반드시 사용자에게 질문하세요.**

---

## Important Notes for AI/Claude Code

1. **역할별 가이드 우선**: 사용자 역할에 맞는 `.claude/role/{role}/README.md` 파일을 먼저 참조하세요.

2. **서비스별 CLAUDE.md**: 특정 서비스 작업 시 해당 서비스의 `CLAUDE.md` 파일을 먼저 읽으세요.

3. **도메인 용어집 참조**: OrderType, TemperatureType 등 핵심 용어는 `.claude/ai-context/domain-glossary.md`를 참조하세요.

4. **데이터 소유권**: SOMS가 주문 데이터의 Single Source of Truth입니다. 다른 서비스는 이벤트를 구독하거나 API를 통해 조회합니다.

5. **Reactive 패턴**: 대부분의 서비스가 WebFlux를 사용합니다. Mono/Flux 사용법과 에러 처리에 주의하세요.

6. **배포 요청 시**: 반드시 6단계 배포 규칙을 따르세요. 태그 생성(5단계)은 필수입니다.

7. **환경 프로파일**: 모든 서비스는 동일한 환경 프로파일을 지원합니다 (local/dev/stg/perf/prod).

---

## Quick Reference

### 공통 Gradle 명령어
```bash
./gradlew bootRun          # 로컬 실행
./gradlew test             # 테스트
./gradlew build            # 빌드
./gradlew spotlessApply    # 코드 포맷팅
```

### 공통 npm 명령어 (Frontend)
```bash
npm install                # 의존성 설치
npm run dev                # 개발 서버
npm run build:dev          # 개발 빌드
npm run lint               # 린트
```

### 로컬 개발 포트
| 서비스                 | 포트 |
|---------------------|------|
| OMS-PLAN            | 8080 |
| OMS-CORE            | 8081 |

> 상세 개발 가이드는 각 역할별 README.md를 참조하세요.
