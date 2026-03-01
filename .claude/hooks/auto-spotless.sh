#!/bin/bash
# PostToolUse: Java 파일 수정 후 Spotless 자동 포맷팅
INPUT=$(cat /dev/stdin)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ "$TOOL_NAME" =~ ^(Edit|Write)$ ]] && [[ "$FILE_PATH" == *.java ]]; then
  cd "$(echo "$INPUT" | jq -r '.cwd')" 2>/dev/null
  ./gradlew spotlessApply -q 2>/dev/null || true
fi
exit 0
