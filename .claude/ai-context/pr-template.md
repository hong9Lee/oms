# OMS PR 템플릿 가이드

> 이 문서는 모든 OMS 프로젝트에 공통으로 적용되는 PR 템플릿입니다.
> "PR 템플릿 작성해줘" 요청 시 아래 형식을 따릅니다.

---

## 머지 전략

**모든 OMS 저장소는 Rebase and merge를 기본 머지 전략으로 사용합니다.**

- 깃 그래프를 선형(linear)으로 유지하기 위함
- merge commit 생성 금지 (--merge, --squash 사용 X)
- **⚠️ PR 머지는 엔지니어가 직접 수행한다. Agent는 `gh pr merge`를 실행하지 않는다.**

---

## PR 템플릿

```markdown
지라 티켓: https://honggyu.atlassian.net/browse/OMS-XXXX

### PR 요약 ⏱️
-

### 변경된 로직 🎈
- [추가]
- [변경]
- [삭제]

### 테스트 케이스 결과 공유 📷
-

### 체크 리스트 🧸
- [ ] 빌드가 성공하는가?
- [ ] 테스트 코드의 테스트 케이스가 적절하게 고려되었는가?
```

---

## 작성 가이드

### 지라 티켓
- 해당 작업의 Jira 이슈 링크를 기입
- 형식: `https://honggyu.atlassian.net/browse/OMS-XXXX`

### PR 요약
- 1~2문장으로 변경 내용의 핵심을 요약
- 예: "Order 초기화 시 적용되는 디폴트 마감시간을 요구사항에 맞게 수정"

### 변경된 로직
- **[추가]**: 새로운 기능, 파일, 메서드 추가
- **[변경]**: 기존 로직 수정, 값 변경
- **[삭제]**: 제거된 코드, 기능, 파일
- 구체적인 변경 내용을 bullet point로 나열

### 테스트 케이스 결과 공유
- 관련 테스트 실행 결과 기재
- 스크린샷 첨부 권장
- 예: "OrderCreateTest BUILD SUCCESSFUL ✅"

### 체크 리스트
- 빌드 성공 여부 확인
- 테스트 케이스 적절성 검토

---

## AI Context 동기화

> 동기화 매핑 규칙은 `/develop` 스킬 AI_CONTEXT_SYNC 참조

---

## 예시

```markdown
지라 티켓: https://honggyu.atlassian.net/browse/OMS-9999

### PR 요약 ⏱️
- Order 초기화 시 적용되는 디폴트 마감시간을 요구사항에 맞게 수정

### 변경된 로직 🎈
- [변경] LTT 롯데택배 2회차: 18:09:59 → 18:29:59 (+20분)
- [변경] CJDT CJ택배 일요일: 18:09:59 → 18:29:59 (+20분)

### 테스트 케이스 결과 공유 📷
- OrderCreateTest BUILD SUCCESSFUL ✅

### 체크 리스트 🧸
- [x] 빌드가 성공하는가?
- [x] 테스트 코드의 테스트 케이스가 적절하게 고려되었는가?
```
