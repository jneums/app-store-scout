import Principal "mo:base/Principal";
import Result "mo:base/Result";
import McpTypes "mo:mcp-motoko-sdk/mcp/Types";
import Json "mo:json";

import AppStoreAdapter "../AppStoreAdapter";

module ToolContext {
  public type ToolContext = {
    canisterPrincipal : Principal;
    owner : Principal;
    getAdapter : AppStoreAdapter.AdapterResolver;
  };

  public func makeError(message : Text, cb : (Result.Result<McpTypes.CallToolResult, McpTypes.HandlerError>) -> ()) {
    cb(#ok({ content = [#text({ text = "Error: " # message })]; isError = true; structuredContent = null }));
  };

  public func makeSuccess(structured : Json.Json, cb : (Result.Result<McpTypes.CallToolResult, McpTypes.HandlerError>) -> ()) {
    cb(#ok({ content = [#text({ text = Json.stringify(structured, null) })]; isError = false; structuredContent = ?structured }));
  };

  public func makeTextSuccess(text : Text, cb : (Result.Result<McpTypes.CallToolResult, McpTypes.HandlerError>) -> ()) {
    cb(#ok({ content = [#text({ text = text })]; isError = false; structuredContent = null }));
  };
}
