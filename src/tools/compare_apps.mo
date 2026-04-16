import Array "mo:base/Array";
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

  func comparisonJson(app : AppStoreData.AppComparison) : Json.Json {
    Json.obj([
      ("appId", Json.str(app.appId)),
      ("name", Json.str(app.name)),
      ("category", Json.str(app.category)),
      ("verificationTier", Json.str(app.verificationTier)),
      ("publisher", Json.str(app.publisher)),
      ("tags", Json.arr(Array.map<Text, Json.Json>(app.tags, Json.str))),
      ("repoUrl", textOrNull(app.repoUrl)),
      ("keyStrengths", Json.arr(Array.map<Text, Json.Json>(app.keyStrengths, Json.str))),
      ("possibleRisks", Json.arr(Array.map<Text, Json.Json>(app.possibleRisks, Json.str)))
    ])
  };

  public func config() : McpTypes.Tool = {
    name = "compare_apps";
    title = ?"Compare Apps";
    description = ?"Compare 2 to 5 apps side by side.";
    payment = null;
    inputSchema = Json.obj([
      ("type", Json.str("object")),
      ("properties", Json.obj([
        ("appIds", Json.obj([
          ("type", Json.str("array")),
          ("items", Json.obj([("type", Json.str("string"))])),
          ("minItems", Json.int(2)),
          ("maxItems", Json.int(5))
        ]))
      ])),
      ("required", Json.arr([Json.str("appIds")]))
    ]);
    outputSchema = ?Json.obj([
      ("type", Json.str("object")),
      ("properties", Json.obj([
        ("comparisons", Json.obj([("type", Json.str("array")), ("items", Json.obj([("type", Json.str("object"))]))])),
        ("comparisonDimensions", Json.obj([("type", Json.str("array")), ("items", Json.obj([("type", Json.str("string"))]))]))
      ]))
    ]);
  };

  public func handle(_context : ToolContext.ToolContext) : (
    _args : McpTypes.JsonValue,
    _auth : ?AuthTypes.AuthInfo,
    cb : (Result.Result<McpTypes.CallToolResult, McpTypes.HandlerError>) -> ()
  ) -> async () {
    func(args : McpTypes.JsonValue, _auth : ?AuthTypes.AuthInfo, cb : (Result.Result<McpTypes.CallToolResult, McpTypes.HandlerError>) -> ()) : async () {
      let appIds = switch (Result.toOption(Json.getAsArray(args, "appIds"))) {
        case (?values) {
          Array.mapFilter<McpTypes.JsonValue, Text>(values, func(value) {
            switch (value) {
              case (#string(text)) ?text;
              case (_) null;
            }
          });
        };
        case (null) {
          return ToolContext.makeError("INVALID_INPUT: Missing 'appIds'", cb);
        };
      };

      if (appIds.size() < 2 or appIds.size() > 5) {
        return ToolContext.makeError("INVALID_INPUT: 'appIds' must contain between 2 and 5 app ids", cb);
      };

      let adapter = _context.getAdapter();
      let comparisons = await adapter.compareApps(appIds);
      if (comparisons.size() == 0) {
        return ToolContext.makeError("NOT_FOUND: No matching apps found", cb);
      };

      ToolContext.makeSuccess(
        Json.obj([
          ("comparisons", Json.arr(Array.map<AppStoreData.AppComparison, Json.Json>(comparisons, comparisonJson))),
          (
            "comparisonDimensions",
            Json.arr([
              Json.str("category"),
              Json.str("verificationTier"),
              Json.str("publisher"),
              Json.str("tags"),
              Json.str("repoUrl"),
              Json.str("keyStrengths"),
              Json.str("possibleRisks")
            ])
          )
        ]),
        cb,
      );
    };
  };
}
