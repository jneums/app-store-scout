# App Store Scout → Prometheus Protocol Hookup Plan

## Canonical source
Use the Prometheus Protocol `mcp_registry` canister as the live discovery backend.

- Canister name: `mcp_registry`
- Mainnet canister id: `grhdx-gqaaa-aaaai-q32va-cai`

## Canonical query methods
### `get_app_listings`
```candid
get_app_listings: (req: AppListingRequest) -> (AppListingResponse) query;
```
Use for:
- search/discovery
- category aggregation
- tag aggregation
- recent releases feed

### `get_app_details_by_namespace`
```candid
get_app_details_by_namespace: (namespace: text, opt_wasm_id: opt text) -> (Result_4) query;
```
Use for:
- full app details
- compare_apps enrichment
- certificate summary base data

### Supporting methods
```candid
get_verification_request: (wasm_id: text) -> (opt VerificationRequest) query;
get_audit_records_for_wasm: (wasm_id: text) -> (vec AuditRecord) query;
```
Use for:
- repo / commit provenance
- audit record enrichment
- certificate summary details

## Mapping strategy
- `appId` in App Store Scout should map to Prometheus `namespace`
- `verificationTier` maps from `SecurityTier`
- release ordering maps from `latest_version.created`
- `certificate summary` is derived from `latest_version`, `build_info`, `data_safety`, and audit records

## Dev workflow
1. Build locally for compile/test correctness.
2. Deploy a dev canister on mainnet.
3. Hook the dev canister to real Prometheus mainnet canisters.
4. Validate output against actual App Store data.
5. When ready, deploy the production App Store Scout and retire the dev canister.

## Important implementation note
A canister cannot directly use JS-style generated declarations. For Motoko, the live adapter should be implemented using Motoko actor bindings / Candid interface declarations for `mcp_registry` query methods.

## Immediate next engineering task
Refactor the server to support an adapter interface:
- `MockAppStoreAdapter` for local tests
- `McpRegistryAdapter` for mainnet dev / production

Then add canister init config or a compile-time configuration path to select mock vs live mode.
