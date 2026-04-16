/**
 * Tool-Specific Test Suite
 */

import { describe, beforeAll, afterAll, it, expect, inject } from 'vitest';
import { PocketIc, createIdentity } from '@dfinity/pic';
import { IDL } from '@icp-sdk/core/candid';
import { AnonymousIdentity } from '@icp-sdk/core/agent';
import { idlFactory as mcpServerIdlFactory } from '../.dfx/local/canisters/app_store_scout/service.did.js';
import type { _SERVICE as McpServerService } from '../.dfx/local/canisters/app_store_scout/service.did.d.ts';
import type { Actor } from '@dfinity/pic';
import path from 'node:path';

const MCP_SERVER_WASM_PATH = path.resolve(
  __dirname,
  '../.dfx/local/canisters/app_store_scout/app_store_scout.wasm',
);

describe('Tool-Specific Tests', () => {
  let pic: PocketIc;
  let serverActor: Actor<McpServerService>;
  let canisterId: any;
  let testOwner = createIdentity('test-owner');

  beforeAll(async () => {
    const picUrl = inject('PIC_URL');

    pic = await PocketIc.create(picUrl);
    canisterId = await pic.createCanister();

    const initArg = IDL.encode(
      [IDL.Opt(IDL.Record({ owner: IDL.Opt(IDL.Principal) }))],
      [[{ owner: [testOwner.getPrincipal()] }]],
    );

    await pic.installCode({
      canisterId,
      wasm: MCP_SERVER_WASM_PATH,
      arg: initArg.buffer as ArrayBufferLike,
    });

    serverActor = pic.createActor<McpServerService>(
      mcpServerIdlFactory,
      canisterId,
    );
  });

  afterAll(async () => {
    await pic?.tearDown();
  });

  async function callTool(name: string, args: Record<string, unknown>) {
    serverActor.setIdentity(new AnonymousIdentity());

    const rpcPayload = {
      jsonrpc: '2.0',
      method: 'tools/call',
      params: {
        name,
        arguments: args,
      },
      id: `test-${name}`,
    };

    const body = new TextEncoder().encode(JSON.stringify(rpcPayload));
    const httpResponse = await serverActor.http_request_update({
      method: 'POST',
      url: '/mcp',
      headers: [['Content-Type', 'application/json']],
      body,
      certificate_version: [],
    });

    expect(httpResponse.status_code).toBe(200);

    return JSON.parse(new TextDecoder().decode(httpResponse.body as Uint8Array));
  }

  it('search_apps should return matching apps', async () => {
    const responseBody = await callTool('search_apps', { query: 'game' });
    expect(responseBody.result.isError).toBe(false);
    const parsed = JSON.parse(responseBody.result.content[0].text);
    expect(Array.isArray(parsed.results)).toBe(true);
    expect(parsed.results.length).toBeGreaterThan(0);
    expect(parsed.results[0]).toHaveProperty('appId');
  });

  it('get_app_details should return an app record', async () => {
    const responseBody = await callTool('get_app_details', { appId: 'app-store-scout' });
    expect(responseBody.result.isError).toBe(false);
    const parsed = JSON.parse(responseBody.result.content[0].text);
    expect(parsed.app.appId).toBe('app-store-scout');
    expect(parsed.app.keyFeatures.length).toBeGreaterThan(0);
  });

  it('get_certificate_summary should return certificate data', async () => {
    const responseBody = await callTool('get_certificate_summary', { appId: 'verifier-watch' });
    expect(responseBody.result.isError).toBe(false);
    const parsed = JSON.parse(responseBody.result.content[0].text);
    expect(parsed.certificate.tier).toBe('silver');
  });

  it('list_recent_releases should return releases', async () => {
    const responseBody = await callTool('list_recent_releases', { limit: 3 });
    expect(responseBody.result.isError).toBe(false);
    const parsed = JSON.parse(responseBody.result.content[0].text);
    expect(parsed.releases.length).toBeGreaterThan(0);
  });

  it('list_categories should return category counts', async () => {
    const responseBody = await callTool('list_categories', {});
    expect(responseBody.result.isError).toBe(false);
    const parsed = JSON.parse(responseBody.result.content[0].text);
    expect(parsed.categories.some((c: any) => c.name === 'Games')).toBe(true);
  });

  it('list_tags should return tags for a category', async () => {
    const responseBody = await callTool('list_tags', { category: 'Discovery' });
    expect(responseBody.result.isError).toBe(false);
    const parsed = JSON.parse(responseBody.result.content[0].text);
    expect(parsed.tags.some((t: any) => t.name === 'search')).toBe(true);
  });

  it('compare_apps should compare two apps', async () => {
    const responseBody = await callTool('compare_apps', {
      appIds: ['app-store-scout', 'governance-copilot'],
    });
    expect(responseBody.result.isError).toBe(false);
    const parsed = JSON.parse(responseBody.result.content[0].text);
    expect(parsed.comparisons.length).toBe(2);
    expect(parsed.comparisonDimensions).toContain('verificationTier');
  });

  it('compare_apps should reject too few app ids', async () => {
    const responseBody = await callTool('compare_apps', {
      appIds: ['app-store-scout'],
    });
    expect(responseBody.result.isError).toBe(true);
    expect(responseBody.result.content[0].text).toContain('between 2 and 5');
  });
});
