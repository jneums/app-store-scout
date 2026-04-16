import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Json "mo:json";

import McpTypes "mo:mcp-motoko-sdk/mcp/Types";
import AuthTypes "mo:mcp-motoko-sdk/auth/Types";

import ToolContext "ToolContext";
import AppStoreData "../AppStoreData";

module {
  func appSummaryJson(app : AppStoreData.AppSummary) : Json.Json {
    Json.obj([
      ("appId", Json.str(app.appId)),
      ("name", Json.str(app.name)),
      ("publisher", Json.str(app.publisher)),
      ("category", Json.str(app.category)),
      ("shortDescription", Json.str(app.shortDescription)),
      ("verificationTier", Json.str(app.verificationTier)),
      ("tags", Json.arr(Array.map<Text, Json.Json>(app.tags, Json.str))),
      ("mcpUrl", switch (app.mcpUrl) { case (?v) Json.str(v); case null Json.nullable() }),
      ("certificateUrl", switch (app.certificateUrl) { case (?v) Json.str(v); case null Json.nullable() })
    ])
  };

  public func config() : McpTypes.Tool = {
    name = "search_apps";
    title = ?"Search App Store Apps";
    description = ?"Search apps by keyword, category, verification tier, and tag.";
    payment = null;
    inputSchema = Json.obj([
      ("type", Json.str("object")),
      ("properties", Json.obj([
        ("query", Json.obj([("type", Json.str("string"))])),
        ("category", Json.obj([("type", Json.str("string"))])),
        ("verificationTier", Json.obj([("type", Json.str("string"))])),
        ("tag", Json.obj([("type", Json.str("string"))])),
        ("limit", Json.obj([("type", Json.str("number"))]))
      ]))
    ]);
    outputSchema = ?Json.obj([
      ("type", Json.str("object")),
      ("properties", Json.obj([
        ("results", Json.obj([("type", Json.str("array")), ("items", Json.obj([("type", Json.str("object"))]))])),
        ("totalMatched", Json.obj([("type", Json.str("number"))])),
        ("sourceUpdatedAt", Json.obj([("type", Json.str("string"))])),
        ("fetchedAt", Json.obj([("type", Json.str("string"))])),
        ("freshness", Json.obj([("type", Json.str("string"))]))
      ]))
    ]);
  };

  public func handle(_context : ToolContext.ToolContext) : (
    _args : McpTypes.JsonValue,
    _auth : ?AuthTypes.AuthInfo,
    cb : (Result.Result<McpTypes.CallToolResult, McpTypes.HandlerError>) -> ()
  ) -> async () {
    func(args : McpTypes.JsonValue, _auth : ?AuthTypes.AuthInfo, cb : (Result.Result<McpTypes.CallToolResult, McpTypes.HandlerError>) -> ()) : async () {
      let searchQuery = switch (Result.toOption(Json.getAsText(args, "query"))) {
        case (?value) value;
        case (null) "";
      };
      let category = Result.toOption(Json.getAsText(args, "category"));
      let verificationTier = Result.toOption(Json.getAsText(args, "verificationTier"));
      let tag = Result.toOption(Json.getAsText(args, "tag"));
      let rawLimit = switch (Result.toOption(Json.getAsNat(args, "limit"))) {
        case (?value) value;
        case (null) 10;
      };
      let limit = Nat.min(rawLimit, 50);
      let adapter = _context.getAdapter();
      let results = await adapter.searchApps({
        searchText = searchQuery;
        category = category;
        verificationTier = verificationTier;
        tag = tag;
        limit = limit;
      });
      let totalMatched = results.size();

      let payload = Json.obj([
        ("results", Json.arr(Array.map<AppStoreData.AppSummary, Json.Json>(results, appSummaryJson))),
        ("totalMatched", Json.int(totalMatched)),
        ("sourceUpdatedAt", Json.str(adapter.getSourceMeta().sourceUpdatedAt)),
        ("fetchedAt", Json.str(adapter.getSourceMeta().fetchedAt)),
        ("freshness", Json.str(adapter.getSourceMeta().freshness))
      ]);

      ToolContext.makeSuccess(payload, cb);
    };
  };
}
