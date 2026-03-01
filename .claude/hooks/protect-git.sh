#!/bin/bash
# OMS PreToolUse Hook: main 브랜치 보호, gh pr merge 차단, 브랜치 네이밍 검증
# exit 0 = 허용, exit 2 = 차단 (stderr 메시지가 Agent에게 전달됨)

COMMAND=$(jq -r '.tool_input.command' < /dev/stdin)

# 1. gh pr merge 절대 차단
if echo "$COMMAND" | grep -qE 'gh\s+pr\s+merge'; then
  echo "BLOCKED: gh pr merge는 Agent가 실행할 수 없습니다. 엔지니어가 직접 머지하세요." >&2
  exit 2
fi

# 2. git push to main/master 차단
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*\b(main|master)\b'; then
  echo "BLOCKED: main 브랜치에 직접 push 금지. feature 브랜치 → PR로 반영하세요." >&2
  exit 2
fi

# 3. git commit on main/master branch 차단
if echo "$COMMAND" | grep -qE 'git\s+commit'; then
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
    echo "BLOCKED: main 브랜치에서 직접 커밋 금지. feature 브랜치를 생성하세요." >&2
    exit 2
  fi
fi

# 4. 브랜치 네이밍 검증 (git checkout -b)
if echo "$COMMAND" | grep -qE 'git\s+checkout\s+-b\s+'; then
  BRANCH_NAME=$(echo "$COMMAND" | grep -oP 'git\s+checkout\s+-b\s+\K\S+')
  if [[ -n "$BRANCH_NAME" ]] && ! echo "$BRANCH_NAME" | grep -qE '^(feature|fix|chore|refactor)/'; then
    echo "BLOCKED: 브랜치명은 {type}/{description} 형식이어야 합니다. type: feature, fix, chore, refactor" >&2
    exit 2
  fi
fi

exit 0
