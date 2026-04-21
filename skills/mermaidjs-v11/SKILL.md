---
name: mermaidjs-v11
description: >
  Create diagrams with Mermaid.js v11 syntax. Use for flowcharts, sequence
  diagrams, ER diagrams, and architecture diagrams inside plan files and docs.
  Activated by planner agent when visualising system flows.
argument-hint: "[diagram-type or description]"
---

# mermaidjs-v11 — Diagram Generation

## Overview

Create text-based diagrams using Mermaid.js v11 declarative syntax.
Used in plan files and README docs to visualise flows for non-dev users.

## Common Diagram Types for taw-kit

- `flowchart` — user flows, feature decision trees
- `sequenceDiagram` — auth flows, payment webhook sequences
- `erDiagram` — Supabase table relationships
- `stateDiagram` — booking/order status machines

## Inline Markdown Usage

````markdown
```mermaid
flowchart TD
    A[Nguoi dung nhap /taw] --> B{Xac nhan ke hoach?}
    B -->|Co| C[Tao du an]
    B -->|Khong| D[Chinh sua]
```
````

## Configuration via Frontmatter

````markdown
```mermaid
---
theme: neutral
---
erDiagram
    USERS ||--o{ ORDERS : places
    ORDERS ||--|{ ITEMS : contains
```
````

## v11 Key Rules

- Use `flowchart` not `graph` (deprecated in v11)
- Node labels with spaces must be quoted: `A["Ten san pham"]`
- Subgraphs: `subgraph Title` ... `end`
- Comments: `%% nay la ghi chu`
- Arrow types: `-->` (normal), `-.->` (dashed), `==>` (thick)

## Sequence Diagram Example

```mermaid
sequenceDiagram
    Khach->>Website: Bam Mua hang
    Website->>Polar: Tao checkout session
    Polar-->>Website: Tra ve URL thanh toan
    Website-->>Khach: Chuyen trang thanh toan
```

## ER Diagram Example

```mermaid
erDiagram
    USERS {
        uuid id PK
        text email
        timestamp created_at
    }
    ORDERS {
        uuid id PK
        uuid user_id FK
        text status
    }
    USERS ||--o{ ORDERS : places
```

## Rendering

- In GitHub/GitLab markdown: renders automatically in code blocks
- In plan files: use fenced code blocks with `mermaid` language tag
- CLI render: `npx @mermaid-js/mermaid-cli -i diagram.mmd -o diagram.svg`
