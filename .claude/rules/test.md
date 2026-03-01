---
paths:
  - "**/src/test/**"
---
# 테스트 컨벤션 (상세: /test-guide 스킬)

- 사용자가 테스트 작성을 요청하지 않았으면 테스트 코드 작성 금지
- 한글 메서드명: {조건이면}_{결과} (예: 정상요청이면_일괄저장된다)
- @Nested + @DisplayName으로 기능별 그룹핑
- 단위 테스트: // given, // when, // then 주석
- 통합 테스트: // 1. 설명, // 2. 설명 순차 주석
- 공유 데이터는 Fixture 팩토리 (fixture/), 복잡한 Port 스텁은 Fake (fake/)
