#!/bin/bash
# OMS PreToolUse Hook: MANUAL_ONLY 파일 보호
# Edit/Write 시 대상 파일이 MANUAL_ONLY 목록이면 사용자 확인 요청 (ask)
# exit 0 + permissionDecision: "ask" = 사용자에게 확인 요청

INPUT=$(cat /dev/stdin)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
FILE_PATH=""

if [[ "$TOOL_NAME" == "Edit" ]]; then
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path')
elif [[ "$TOOL_NAME" == "Write" ]]; then
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path')
fi

# 파일 경로가 없으면 허용
if [[ -z "$FILE_PATH" || "$FILE_PATH" == "null" ]]; then
  exit 0
fi

# MANUAL_ONLY 패턴 매칭
IS_PROTECTED=false

case "$FILE_PATH" in
  */SKILL.md)          IS_PROTECTED=true ;;
  */CLAUDE.md)         IS_PROTECTED=true ;;
  */role/*/README.md)  IS_PROTECTED=true ;;
  */deploy-guide.md)   IS_PROTECTED=true ;;
  */settings.json)     IS_PROTECTED=true ;;
  */settings.local.json) IS_PROTECTED=true ;;
esac

if [[ "$IS_PROTECTED" == "true" ]]; then
  FILENAME=$(basename "$FILE_PATH")
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "${FILENAME}은 MANUAL_ONLY 파일입니다. 사용자가 수정을 요청했는지 확인하세요."
  }
}
EOF
  exit 0
fi

exit 0
