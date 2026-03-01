---
paths:
  - "**/adapter/in/web/**"
---
# Controller 컨벤션 (상세: /convention 스킬)

- @Slf4j + @RestController + @RequestMapping + @RequiredArgsConstructor
- UseCase 인터페이스 주입 (구현체 직접 주입 금지)
- ResponseEntity<T> 반환
- Request/Response DTO는 record 사용
- private 메서드 호출 시 this. prefix 필수
