import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Json "mo:json";

import McpTypes "mo:mcp-motoko-sdk/mcp/Types";
import AuthTypes "mo:mcp-motoko-sdk/auth/Types";

import ToolContext "ToolContext";
import AppStoreData "../AppStoreData";

module {
  func textOrNull(value : ?Text) : Json.Json {
    switch (value) {
      case (?v) Json.str(v);
      case (null) Json.nullable();
    }
  };

  func releaseJson(release : AppStoreData.ReleaseSummary) : Json.Json {
    Json.obj([
      ("appId", Json.str(release.appId)),
      ("name", Json.str(release.name)),
      ("version", textOrNull(release.version)),
      ("releasedAt", textOrNull(release.releasedAt)),
      ("verificationStatus", textOrNull(release.verificationStatus)),
      ("tier", textOrNull(release.tier))
    ])
  };

  public func config() : McpTypes.Tool = {
    name = "list_recent_releases";
    title = ?"List Recent Releases";
    description = ?"List newly published or recently updated apps.";
    payment = null;
    inputSchema = Json.obj([
      ("type", Json.str("object")),
      ("properties", Json.obj([
        ("limit", Json.obj([("type", Json.str("number"))])),
        ("category", Json.obj([("type", Json.str("string"))]))
      ]))
    ]);
    outputSchema = ?Json.obj([
      ("type", Json.str("object")),
      ("properties", Json.obj([
        ("releases", Json.obj([("type", Json.str("array")), ("items", Json.obj([("type", Json.str("object"))]))]))
      ]))
    ]);
  };

  public func handle(_context : ToolContext.ToolContext) : (
    _args : McpTypes.JsonValue,
    _auth : ?AuthTypes.AuthInfo,
    cb : (Result.Result<McpTypes.CallToolResult, McpTypes.HandlerError>) -> ()
  ) -> async () {
    func(args : McpTypes.JsonValue, _auth : ?AuthTypes.AuthInfo, cb : (Result.Result<McpTypes.CallToolResult, McpTypes.HandlerError>) -> ()) : async () {
      let rawLimit = switch (Result.toOption(Json.getAsNat(args, "limit"))) {
        case (?value) value;
        case (null) 10;
      };
      let limit = Nat.min(rawLimit, 50);
      let category = Result.toOption(Json.getAsText(args, "category"));
      let adapter = _context.getAdapter();
      let releases = await adapter.listRecentReleases(limit, category);
      ToolContext.makeSuccess(
        Json.obj([
          ("releases", Json.arr(Array.map<AppStoreData.ReleaseSummary, Json.Json>(releases, releaseJson))),
          ("sourceUpdatedAt", Json.str(adapter.getSourceMeta().sourceUpdatedAt))
        ]),
        cb,
      );
    };
  };
}
