# App Store Scout

A Prometheus-native Motoko MCP server for discovering, inspecting, and comparing apps in the Prometheus App Store.

## Production status
App Store Scout now supports two runtime modes:
- **mock mode** for local development/tests
- **live registry mode** backed by the Prometheus `mcp_registry` canister on mainnet

Default live registry canister:
- `grhdx-gqaaa-aaaai-q32va-cai`

Mainnet dev canister used for live QA:
- `jnyxn-waaaa-aaaab-agoda-cai`

## Tools
- `search_apps`
- `get_app_details`
- `get_certificate_summary`
- `list_recent_releases`
- `list_categories`
- `list_tags`
- `compare_apps`

## Local development
```bash
npm install
npm run mops:install
dfx start --background
npm run deploy
npm test
```

## MCP Inspector
```bash
npm run inspector
```
Then connect to:
```text
http://127.0.0.1:4943/mcp/?canisterId=<your_canister_id>
```

## Runtime configuration
Prometheus Protocol handles deployment, so live configuration is controlled with owner-only setter methods instead of constructor config.

Available config methods:
- `get_live_mode()`
- `set_live_mode(Bool)`
- `get_registry_canister_id()`
- `set_registry_canister_id(Principal)`

Example post-deploy config:
```bash
dfx canister --network ic call app_store_scout set_registry_canister_id '(principal "grhdx-gqaaa-aaaai-q32va-cai")'
dfx canister --network ic call app_store_scout set_live_mode '(true)'
```

## Notes
- Tools are public/free for the current MVP.
- `prometheus.yml` is included.
- Live discovery reads from the Prometheus `mcp_registry` canister.
- Some production polish remains possible, such as friendlier timestamp formatting and richer certificate URL derivation.
