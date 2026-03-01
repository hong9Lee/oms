# OMS MSA 도메인 용어집

이 문서는 OMS MSA 전체에서 공통으로 사용되는 핵심 도메인 용어를 정의합니다.

---

## 1. 배송 관련 용어

### DeliveryPolicy (배송 정책)

| 값 | 설명 |
|----|------|
| DAWN | 새벽배송 (샛별) |
| DAY | 일반배송 (낮배송) |
| NOW | 즉시배송 |

### Courier (배송사)

| 코드 | 설명 | 배송 유형 |
|------|------|----------|
| 1PL | 자사 물류센터 배송 | 새벽배송 (DAWN) |
| CJDT (CJ) | CJ대한통운 | 일반배송 (DAY) |
| LTT | 롯데택배 | 일반배송 (DAY) |

### 1P vs 3P

| 용어 | 설명 |
|------|------|
| 1P (First Party) | 자사 물류센터에서 직접 처리 |
| 3P (Third Party Logistics) | 외부 3PL 센터에서 처리 |

---

## 2. 주문 관련 용어

### 주문 코드 체계

| 코드 | 설명 | 예시 |
|------|------|------|
| outboundOrderCode | 출고요청번호 (OMS 채번) | "O-20241216-001" |
| clientOrderCode | 고객주문번호 (외부 시스템) | "C-12345" |
| shipOrderKey | 출하문서번호 (WMS) | "SHK-001" |
| invoiceNumber | 운송장번호 | "123456789012" |

### OrderStatus (주문 상태)

| 값 | 설명 |
|----|------|
| RECEIVED | 주문 접수 완료 |
| PROCESSING | 처리 중 |
| COMPLETED | 완료 |
| CANCELED | 취소됨 |

### OutboundStatus (출고 상태)

```
READY → PRODUCING → COMPLETED
  ↓
CANCELED
```

| 값 | 설명 |
|----|------|
| READY | 출고 준비 |
| PRODUCING | 생산 중 (피킹/패킹) |
| COMPLETED | 출고 완료 |
| CANCELED | 취소됨 |

---

## 3. 권역 관련 용어

### ClusterCenter (클러스터센터)

| 코드 | 설명 |
|------|------|
| CC01 | 김포 물류센터 |
| CC02 | 송파 물류센터 |

---

## 4. 외부 시스템

| 약어 | 전체명 | 설명 |
|------|--------|------|
| WMS | Warehouse Management System | 창고관리시스템 |
| CMS | Commerce Management System | 커머스 시스템 |

---

## 5. 자주 혼동되는 용어

### Courier vs DeliveryPolicy

- **Courier**: 배송사 (1PL, CJ, LTT)
- **DeliveryPolicy**: 배송 정책 (DAWN, DAY, NOW)
