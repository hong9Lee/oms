#!/bin/bash
# PreCompact: 컨텍스트 압축 시 OMS 핵심 규칙 재주입 (stdout → 압축 후 컨텍스트에 추가)
cat <<'CONTEXT'
[OMS 핵심 컨텍스트 — 상세는 각 스킬 참조]
- 아키텍처: /develop 스킬 ARCHITECTURE 섹션
- 코드 컨벤션: /convention 스킬
- 테스트: /test-guide 스킬
- git: /develop 스킬 GIT_RULES 섹션
- 서비스별 오버라이드: {서비스}/.claude/ai-context/development-guide.md
CONTEXT
exit 0
