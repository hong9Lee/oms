---
name: deploy
description: |
  OMS MSA 배포 준비 절차.
  사용자가 "배포", "deploy", "릴리스", "버전 업", "태그" 등을 말할 때 사용.
  배포 6단계 절차와 버전 규칙을 정의한다.
allowed-tools: Read, Edit, Bash, Grep, Glob
---

# OMS MSA Deploy Skill

> 배포 요청 시 반드시 해당 MSA 프로젝트의 CLAUDE.md를 먼저 읽고 진행한다.

## 배포 준비 6단계

| 단계 | 작업 | 설명 |
|------|------|------|
| **1** | 현재 버전 및 변경 내용 확인 | `ServerPropertiesController.java`에서 현재 버전 확인, 이전 태그 이후 변경 내용 분석 |
| **2** | 배포 제목 작성 | 변경 내용을 분석하여 배포 제목을 AI가 직접 작성 |
| **3** | 버전 업데이트 | `ServerPropertiesController.java`의 버전을 +1 증가 |
| **4** | master 브랜치에 커밋 & push | 버전 변경 사항을 커밋하고 push |
| **5** | 태그 생성 & push | 새 버전으로 Git 태그 생성 및 push |
| **6** | 운영배포 요청서 작성 | oms-tools 스크립트로 Jira 서비스데스크 폼 자동 입력 |

---

## 실행 명령어

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

---

## 버전 규칙

- 형식: `v{major}.{minor}.{patch}` (예: v3.3.17)
- 일반 배포: patch 버전 +1 (3.3.17 → 3.3.18)
- 주요 기능 추가: minor 버전 +1 (3.3.x → 3.4.0)

---

## 배포 전 필수 확인사항

| 필수 정보 | 설명 | 예시 |
|----------|------|------|
| **프로젝트** | 어떤 서비스를 배포할지 | oms-plan, oms-core 등 |
| **PR URL** | 배포 기준이 되는 PR 링크 | https://github.com/hong9Lee/oms-plan/pull/123 |

**⚠️ PR 링크가 없으면 반드시 사용자에게 질문하세요.**
