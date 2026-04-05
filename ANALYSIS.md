# MiroFish Codebase Analysis

## Project Overview

**MiroFish**는 멀티 에이전트 기반 AI 예측 엔진으로, 문서에서 지식 그래프를 구축하고 소셜 미디어 시뮬레이션을 통해 미래를 예측하는 풀스택 애플리케이션입니다.

- **라이선스**: AGPL-3.0
- **개발팀**: 666ghj (Shanda Group)
- **저장소**: `ghcr.io/666ghj/mirofish`

---

## Tech Stack

| 영역 | 기술 |
|------|------|
| **Frontend** | Vue 3.5 + Vite 7.2 + Vue Router + vue-i18n + D3.js |
| **Backend** | Python 3.11 + Flask 3.0 |
| **LLM** | OpenAI-compatible API (Alibaba Qwen 권장) |
| **Knowledge Graph** | Zep Cloud (GraphRAG) |
| **Simulation** | CAMEL-OASIS 0.2.5 (Twitter/Reddit 시뮬레이션) |
| **DevOps** | Docker + Docker Compose + GitHub Actions |
| **패키지 관리** | npm (Frontend) + uv (Backend) |

---

## Architecture (5-Step Workflow)

```
Step 1: Graph Building     - 문서 업로드 → 온톨로지 생성 → Zep 지식 그래프 구축
Step 2: Environment Setup  - 엔티티 추출 → 에이전트 페르소나 생성
Step 3: Simulation         - OASIS로 Twitter/Reddit 병렬 시뮬레이션 실행
Step 4: Report Generation  - ReACT 패턴의 ReportAgent가 분석 보고서 생성
Step 5: Deep Interaction   - 시뮬레이션된 에이전트와 대화형 인터뷰
```

---

## Project Structure

```
MiroFish/
├── backend/                           # Python Flask 백엔드
│   ├── run.py                         # 진입점 (port 5001)
│   ├── pyproject.toml                 # Python 의존성
│   ├── app/
│   │   ├── __init__.py                # Flask 앱 팩토리
│   │   ├── config.py                  # 설정 관리
│   │   ├── api/                       # API 라우트 (3 블루프린트)
│   │   │   ├── graph.py               # 그래프 빌딩 API (622줄)
│   │   │   ├── simulation.py          # 시뮬레이션 API (2,716줄)
│   │   │   └── report.py              # 리포트 생성 API (1,020줄)
│   │   ├── services/                  # 핵심 비즈니스 로직 (13개 모듈)
│   │   │   ├── ontology_generator.py  # LLM 기반 온톨로지 생성
│   │   │   ├── graph_builder.py       # Zep 그래프 구축
│   │   │   ├── zep_entity_reader.py   # 엔티티 필터링/조회
│   │   │   ├── oasis_profile_generator.py # 에이전트 페르소나 생성 (1,205줄)
│   │   │   ├── simulation_manager.py  # 시뮬레이션 상태 관리
│   │   │   ├── simulation_runner.py   # OASIS 실행 엔진 (1,768줄)
│   │   │   ├── simulation_config_generator.py # 시뮬 설정 자동 생성
│   │   │   ├── simulation_ipc.py      # 프로세스간 통신 (IPC)
│   │   │   ├── report_agent.py        # ReACT 리포트 에이전트 (2,572줄)
│   │   │   ├── zep_tools.py           # Zep 도구 서비스 (1,736줄)
│   │   │   ├── zep_graph_memory_updater.py # 그래프 실시간 업데이트
│   │   │   └── text_processor.py      # 텍스트 청킹/전처리
│   │   ├── models/                    # 데이터 모델
│   │   │   ├── project.py             # 프로젝트 관리 (상태 머신)
│   │   │   └── task.py                # 비동기 태스크 추적
│   │   └── utils/                     # 유틸리티
│   │       ├── llm_client.py          # OpenAI 호환 LLM 클라이언트
│   │       ├── file_parser.py         # PDF/MD/TXT 파서
│   │       ├── logger.py              # 구조화 로깅
│   │       ├── locale.py              # i18n (EN/ZH)
│   │       ├── retry.py               # 지수 백오프 재시도
│   │       └── zep_paging.py          # Zep 페이지네이션
│   └── scripts/                       # 테스트/유틸 스크립트
│
├── frontend/                          # Vue 3 프론트엔드
│   ├── src/
│   │   ├── main.js                    # 앱 진입점 (port 3000)
│   │   ├── App.vue                    # 루트 컴포넌트
│   │   ├── router/index.js            # 라우터 (5 페이지)
│   │   ├── i18n/index.js              # EN/ZH 국제화
│   │   ├── api/                       # API 클라이언트 (axios)
│   │   ├── views/                     # 페이지 컴포넌트 (7개)
│   │   ├── components/                # 재사용 컴포넌트 (8개)
│   │   └── assets/                    # 정적 자원
│   └── vite.config.js                 # Vite 설정 (/api → :5001 프록시)
│
├── locales/                           # 국제화 파일
│   ├── en.json                        # 영어 (1000+ 키)
│   └── zh.json                        # 중국어
│
├── Dockerfile                         # 멀티스테이지 빌드 (python:3.11)
├── docker-compose.yml                 # 컨테이너 오케스트레이션
├── .env.example                       # 환경변수 템플릿
└── .github/workflows/docker-image.yml # CI/CD (GHCR 배포)
```

---

## API Endpoints

### Graph API (`/api/graph/`)
| Method | Endpoint | 설명 |
|--------|----------|------|
| POST | `/ontology/generate` | 문서 업로드 + 온톨로지 생성 |
| POST | `/build` | 비동기 그래프 빌딩 시작 |
| GET | `/task/<task_id>` | 태스크 진행률 조회 |
| GET | `/data/<graph_id>` | 그래프 노드/엣지 조회 |
| GET | `/project/list` | 프로젝트 목록 |
| DELETE | `/project/<id>` | 프로젝트 삭제 |

### Simulation API (`/api/simulation/`)
| Method | Endpoint | 설명 |
|--------|----------|------|
| GET | `/entities/<graph_id>` | 엔티티 목록 조회 |
| POST | `/prepare` | 시뮬레이션 준비 (페르소나 생성) |
| POST | `/<id>/start` | 시뮬레이션 실행 |
| GET | `/<id>/run-status` | 실행 상태 모니터링 |
| POST | `/<id>/stop` | 시뮬레이션 중지 |
| POST | `/<id>/pause` / `/resume` | 일시정지/재개 |
| GET | `/<id>/actions` | 에이전트 행동 로그 |

### Report API (`/api/report/`)
| Method | Endpoint | 설명 |
|--------|----------|------|
| POST | `/generate` | 비동기 리포트 생성 |
| GET | `/<id>/status` | 생성 상태 조회 |
| GET | `/<id>` | 리포트 전문 조회 |
| POST | `/<id>/chat` | ReportAgent와 대화 |
| POST | `/<id>/interview/<entity>` | 에이전트 인터뷰 |
| GET | `/<id>/download` | 리포트 다운로드 |

---

## Key Design Patterns

1. **Factory Pattern**: `create_app()` Flask 팩토리
2. **Singleton + Thread Lock**: `TaskManager`, `SimulationManager`, `ReportManager`
3. **State Machine**: `ProjectStatus`, `SimulationStatus`, `TaskStatus` Enum
4. **Service Layer**: Stateless 서비스 (API → Service → External)
5. **ReACT Pattern**: ReportAgent의 Reasoning-Acting-Thinking 루프
6. **IPC (Named Pipe)**: OASIS 서브프로세스와의 통신
7. **Callback Pattern**: 비동기 작업의 진행률 보고
8. **Repository Pattern**: ProjectManager/ReportManager의 디스크 영속화

---

## External Dependencies

| 서비스 | 용도 | 필수 여부 |
|--------|------|-----------|
| **LLM API** (OpenAI 호환) | 온톨로지/페르소나/리포트 생성 | 필수 |
| **Zep Cloud** | 지식 그래프 저장 + GraphRAG | 필수 |
| **CAMEL-OASIS** | Twitter/Reddit 소셜 시뮬레이션 | 필수 |

환경변수: `LLM_API_KEY`, `LLM_BASE_URL`, `LLM_MODEL_NAME`, `ZEP_API_KEY`

---

## Data Flow

```
문서(PDF/MD/TXT) → 텍스트 추출 → 청킹(500자) → LLM 온톨로지 생성
    → Zep 그래프 구축 → 엔티티 추출 → LLM 페르소나 생성
    → OASIS 시뮬레이션(Twitter+Reddit 병렬) → 에이전트 행동 기록
    → Zep 그래프 업데이트 → ReportAgent 분석 → 예측 리포트
    → 사용자 대화형 인터뷰
```

---

## Code Metrics

| 영역 | 파일 수 | 주요 규모 |
|------|---------|-----------|
| Backend API | 3 | ~4,400줄 |
| Backend Services | 13 | ~15,000줄 |
| Backend Utils | 6 | ~900줄 |
| Backend Models | 2 | ~280줄 |
| Frontend Views | 7 | ~6,000줄 |
| Frontend Components | 8 | ~14,000줄 |
| Locales | 2 | ~74K (1000+ 번역 키) |

---

## Strengths

1. **잘 구조화된 5단계 워크플로우**: 복잡한 파이프라인을 단계별로 명확히 분리
2. **유연한 LLM 통합**: OpenAI 호환 API로 다양한 모델 지원
3. **병렬 시뮬레이션**: Twitter + Reddit 동시 실행
4. **비동기 처리**: 장시간 작업(그래프 빌딩, 시뮬레이션, 리포트)에 태스크 큐 적용
5. **국제화**: EN/ZH 완전 지원
6. **컨테이너화**: Docker + CI/CD 파이프라인 완비

## Potential Improvements

1. **데이터베이스 부재**: 현재 디스크 파일(JSON) 기반 영속화 → SQLite/PostgreSQL 도입 권장
2. **인증/인가 없음**: API 인증 메커니즘 미구현
3. **테스트 부재**: 단위/통합 테스트 없음 (scripts/ 폴더에 수동 테스트만 존재)
4. **에러 핸들링**: 일부 서비스에서 예외 처리가 불충분할 수 있음
5. **프론트엔드 상태관리**: Vuex/Pinia 없이 컴포넌트 로컬 상태만 사용
6. **API 문서화**: Swagger/OpenAPI 스펙 미구현
7. **simulation.py 크기**: 2,716줄로 분리 필요 가능성
