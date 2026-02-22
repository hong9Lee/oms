# OMS MSA 도메인 용어집

이 문서는 OMS MSA 전체에서 공통으로 사용되는 핵심 도메인 용어와 그 관계를 정의합니다.

---

## 1. OrderType과 TemperatureType 관계 (핵심!)

### 개념 정리

| 용어 | 설명 | 예시 |
|------|------|------|
| **OrderType** | 주문 유형을 나타내는 **숫자 코드** | "210", "220", "270" |
| **TemperatureType** | 온도대를 나타내는 **Enum** | COLD, FROZEN, ROOM |

### TemperatureType Enum 정의

```java
public enum TemperatureType {
    //         code,    description, categoryName, dawnOrderType, dayOrderType
    COLD      ("COLD",   "냉장",      "냉장",       "210",         "270"),
    FROZEN    ("FROZEN", "냉동",      "냉동",       "220",         "271"),
    FROZEN_SIOC("FROZEN_SIOC", "냉동SIOC", "냉동", "238",         "278"),
    ROOM      ("ROOM",   "상온",      "상온",       "225",         "272"),
    ROOM_SIOC ("ROOM_SIOC", "상온SIOC", "상온",    "237",         "275"),
    RED       ("RED",    "빨강",      "빨강",       "235",         "273"),
    GREEN     ("GREEN",  "녹색(상온)", "녹색",      "226",         "274"),
    GREEN_EXPENSIVE_APPLIANCE_SIOC("...", "녹색(고가가전)", "녹색", "227", "000"),
    FASHION   ("FASHION", "패션",     "패션",       "242",         "279"),
    FASHION_SIOC("FASHION_SIOC", "패션 SIOC", "패션", "241",       "277");
}
```

### 매핑 테이블

| TemperatureType | 설명 | dawnOrderType | dayOrderType |
|-----------------|------|---------------|--------------|
| COLD | 냉장 | 210 | 270 |
| FROZEN | 냉동 | 220 | 271 |
| FROZEN_SIOC | 냉동 SIOC | 238 | 278 |
| ROOM | 상온 | 225 | 272 |
| ROOM_SIOC | 상온 SIOC | 237 | 275 |
| RED | 빨강 | 235 | 273 |
| GREEN | 녹색(상온) | 226 | 274 |
| FASHION | 패션 | 242 | 279 |
| FASHION_SIOC | 패션 SIOC | 241 | 277 |

### 변환 함수

```java
// OrderType(숫자) → TemperatureType(Enum)
TemperatureType.fromDawnOrderType("210")  // → COLD
TemperatureType.fromDayOrderType("270")   // → COLD

// TemperatureType → OrderType
TemperatureType.COLD.getDawnOrderType()   // → "210"
TemperatureType.COLD.getDayOrderType()    // → "270"
```

### 사용 패턴

**상품(Goods)에서의 사용**:
```json
{
  "goodsCode": "100001234",
  "centerOrderTypes": [
    {
      "clusterCenterCode": "CC01",
      "dawnOrderType": "210",           // 숫자 코드
      "dawnTemperatureType": "COLD",    // Enum (UI 표시용)
      "dayOrderType": "270",            // 숫자 코드
      "dayTemperatureType": "COLD"      // Enum (UI 표시용)
    }
  ]
}
```

---

## 2. 배송 관련 용어

### Courier (배송사)

| 코드 | 설명 | 배송 유형 |
|------|------|----------|
| KURLY | 컬리 자체배송 | 샛별배송 (새벽) |
| CJDT (CJ) | CJ대한통운 | 일반배송 (낮) |
| LTT | 롯데택배 | 일반배송 (낮) |

### DeliveryPolicy (배송 정책)

| 값 | 설명 |
|----|------|
| DAWN | 새벽배송 (샛별) |
| DAY | 일반배송 (낮배송) |
| NOW | 컬리나우 (즉시배송) |

### 1P vs 3P

| 용어 | 설명 |
|------|------|
| 1P (First Party) | 컬리 물류센터에서 직접 처리 |
| 3P (Third Party Logistics) | 외부 3PL 센터에서 처리 |

---

## 3. 주문 관련 용어

### 주문 코드 체계

| 코드 | 설명 | 예시 |
|------|------|------|
| outboundOrderCode | 출고요청번호 (SOMS 채번) | "O-20241216-001" |
| clientOrderCode | 고객주문번호 (외부 시스템) | "C-12345" |
| shipOrderKey | 출하문서번호 (WMS) | "SHK-001" |
| invoiceNumber | 운송장번호 | "123456789012" |

### 주문 상태 (OutboundStatus)

```
READY → PRODUCING → COMPLETED
  ↓
CANCELED
```

---

## 4. 권역 관련 용어

### RegionGroupCode (권역그룹코드)

배송 가능 지역을 그룹핑한 코드. TAM에서 관리.

### ClusterCenter (클러스터센터)

| 코드 | 설명 |
|------|------|
| CC01 | 김포 물류센터 |
| CC02 | 송파 물류센터 |
| 2cc | 김포 (레거시 코드) |
| 34cc | 송파 (레거시 코드) |

### SIOC (Ship In Own Container)

상품 자체 박스로 출고하는 방식. 별도 포장 없이 상품 박스 그대로 배송.

---

## 5. 물류 시스템 연동

### 외부 시스템 약어

| 약어 | 전체명 | 설명 |
|------|--------|------|
| WMS | Warehouse Management System | 창고관리시스템 |
| TMS | Transportation Management System | 운송관리시스템 |
| BTS | ? | 배송 트래킹 시스템 |
| RMS | Return Management System | 반품관리시스템 |
| LIP | Logistics Information Platform | 물류정보플랫폼 (상품 마스터) |
| ESCM | ? | 파트너포탈 (상품 동기화) |
| DOS | Delivery Operation System | 배송운영시스템 |
| CMS | ? | 커머스 시스템 |

### 화주사 관련 (KLS/FBK)

| 용어 | 설명 |
|------|------|
| FBK | Fulfillment By Kurly - 컬리 물류 이용 화주사 |
| KLS | Kurly Logistics Service - FBK와 동의어 |
| NFA | Naver Fulfillment Alliance - 네이버 풀필먼트 연동 |

---

## 6. 자주 혼동되는 용어

### OrderType vs TemperatureType

- **OrderType**: 숫자 코드 ("210", "270") - DB/API 저장용
- **TemperatureType**: Enum (COLD, FROZEN) - 비즈니스 로직/UI 표시용

### dawnOrderType vs dayOrderType

- **dawnOrderType**: 새벽배송(샛별) 주문 유형 코드 (2xx 대역)
- **dayOrderType**: 일반배송(낮) 주문 유형 코드 (27x 대역)

### Courier vs DeliveryPolicy

- **Courier**: 배송사 (KURLY, CJ, LTT)
- **DeliveryPolicy**: 배송 정책 (DAWN, DAY, NOW)

---

## 참고 파일 위치

- TemperatureType Enum: `oms-admin-api/src/main/java/com/kurly/omsAdminApi/core/domain/enums/TemperatureType.java`
- Courier Enum: `oms-admin-api/src/main/java/com/kurly/omsAdminApi/core/domain/enums/Courier.java`
- Goods 도메인: `oms-admin-api/src/main/java/com/kurly/omsAdminApi/core/domain/goods/Goods.java`
