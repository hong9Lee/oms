---
paths:
  - "**/domain/model/**"
  - "**/domain/enums/**"
---
# Domain Model 컨벤션 (상세: /convention 스킬)

- @Getter + @Builder + @AllArgsConstructor
- @Setter 절대 금지 → 의미 있는 메서드로 상태 변경
- 외부에서 상태를 꺼내서 조작 금지 (Tell, Don't Ask)
- 도메인 로직(검증, 상태 변경, 판단)은 모델 내부 메서드로 캡슐화
- List 반복 사용 시 일급 객체로 감싸기 (Order → Orders, OrderItem → OrderItems)
- 일급 객체는 record 선언 가능, compact constructor에서 null → List.of() 정규화
