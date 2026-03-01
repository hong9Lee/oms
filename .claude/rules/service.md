---
paths:
  - "**/application/service/**"
---
# Service 컨벤션 (상세: /convention 스킬)

- @Service + @Slf4j + @RequiredArgsConstructor
- 멤버 순서: static final 상수 → final DI 필드 → @Override public → private 헬퍼
- 다건 저장/변경에는 @Transactional 적용 (Service의 @Override public 메서드)
- private 메서드 호출 시 this. prefix 필수
- 동일 DB 호출 N번 반복 금지 → findByXxxIn + saveAll 사용
