#!/bin/bash
# PreCompact: 컨텍스트 압축 시 OMS 핵심 규칙 재주입 (stdout → 압축 후 컨텍스트에 추가)
cat <<'CONTEXT'
[OMS 핵심 컨텍스트]
- 아키텍처: Hexagonal (Ports & Adapters). 의존성 방향: adapter → application → domain
- 코드 컨벤션: /convention 스킬 참조. @Setter 금지, record 적극 사용, MapStruct 필수
- 테스트: /test-guide 스킬 참조. 한글 메서드명, @Nested 구조, Fixture Factory
- git: 커밋/push/PR은 사용자 키워드 있을 때만. main 직접 커밋 금지 (Hook 차단)
- 서비스별 오버라이드: {서비스}/.claude/ai-context/development-guide.md 참조
CONTEXT
exit 0
