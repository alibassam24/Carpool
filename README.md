# Development Phase


```
USERS (id PK)
 ├── email, role, status, loyalty_points, created_at
 ├─┐
 │ └── 1:1 → PROFILES (id PK, FK users.id)
 │
 ├─┐
 │ └── 1:N → DRIVER_DOCUMENTS (id PK, FK users.id)
 │
 ├─┐
 │ └── 1:N → VEHICLES (id PK, FK users.id)
 │         └── 1:N → RIDES (id PK, FK vehicles.id, FK users.id as carpooler)
 │                 ├── origin, destination, distance, duration, date_time, status
 │                 │
 │                 ├─┐
 │                 │ └── 1:N → RIDE_REQUESTS (id PK, FK rides.id, FK users.id as passenger)
 │                 │        (bridge: Users ↔ Rides, many-to-many)
 │                 │
 │                 ├─┐
 │                 │ └── 1:N → PAYMENTS (id PK, FK rides.id, FK users.id as payer)
 │                 │
 │                 ├─┐
 │                 │ └── 1:N → RIDE_TRACKING (id PK, FK rides.id, live GPS points)
 │                 │
 │                 ├─┐
 │                 │ └── 1:N → CHATS (id PK, FK rides.id, FK users.id sender/receiver)
 │                 │        (bridge: Users ↔ Users, many-to-many per ride)
 │                 │
 │                 ├─┐
 │                 │ └── 1:N → COMPLAINTS (id PK, FK rides.id, FK users.id as complainer)
 │                 │
 │                 ├─┐
 │                 │ └── 1:N → RATINGS (id PK, FK rides.id, reviewer_id FK users.id, reviewee_id FK users.id)
 │                 │        (bridge: Users ↔ Users, many-to-many via ratings)
 │                 │
 │                 └─┐
 │                   └── 1:N → SOS_ALERTS (id PK, FK rides.id, FK users.id)
 │
 ├─┐
 │ └── 1:N → NOTIFICATIONS (id PK, FK users.id)
 │
 └─┐
   └── M:N → PROMO_CODES (id PK, code, discount, validity)
            ↔ USER_PROMOS (id PK, FK users.id, FK promo_codes.id)
            (tracks redemption history)

SETTINGS (id PK)
 ├── petrol_price, updated_at
 └── Managed only by Admin users

```