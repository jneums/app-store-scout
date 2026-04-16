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

  func detailsJson(app : AppStoreData.AppDetails) : Json.Json {
    Json.obj([
      ("appId", Json.str(app.appId)),
      ("name", Json.str(app.name)),
      ("publisher", Json.str(app.publisher)),
      ("category", Json.str(app.category)),
      ("shortDescription", Json.str(app.shortDescription)),
      ("verificationTier", Json.str(app.verificationTier)),
      ("tags", Json.arr(Array.map<Text, Json.Json>(app.tags, Json.str))),
      ("mcpUrl", textOrNull(app.mcpUrl)),
      ("certificateUrl", textOrNull(app.certificateUrl)),
      ("longDescription", textOrNull(app.longDescription)),
      ("whyThisApp", textOrNull(app.whyThisApp)),
      ("keyFeatures", Json.arr(Array.map<Text, Json.Json>(app.keyFeatures, Json.str))),
      ("repoUrl", textOrNull(app.repoUrl)),
      ("iconUrl", textOrNull(app.iconUrl)),
      ("bannerUrl", textOrNull(app.bannerUrl)),
      ("galleryImages", Json.arr(Array.map<Text, Json.Json>(app.galleryImages, Json.str))),
      ("deploymentType", textOrNull(app.deploymentType)),
      ("namespace", textOrNull(app.namespace)),
      ("mcpPath", textOrNull(app.mcpPath)),
      ("gitCommit", textOrNull(app.gitCommit)),
      ("wasmPath", textOrNull(app.wasmPath)),
      (
        "verificationChecklist",
        switch (app.verificationChecklist) {
          case (?checklist) Json.obj([
            ("reproducibleBuild", Json.bool(checklist.reproducibleBuild)),
            ("appInfoComplete", Json.bool(checklist.appInfoComplete)),
            ("toolsReviewed", Json.bool(checklist.toolsReviewed)),
            ("dataSafetyReviewed", Json.bool(checklist.dataSafetyReviewed))
          ]);
          case (null) Json.nullable();
        }
      )
    ])
  };

  public func config() : McpTypes.Tool = {
    name = "get_app_details";
    title = ?"Get App Details";
    description = ?"Return complete metadata for a single app.";
    payment = null;
    inputSchema = Json.obj([
      ("type", Json.str("object")),
      ("properties", Json.obj([
        ("appId", Json.obj([("type", Json.str("string"))]))
      ])),
      ("required", Json.arr([Json.str("appId")]))
    ]);
    outputSchema = ?Json.obj([
      ("type", Json.str("object")),
      ("properties", Json.obj([
        ("app", Json.obj([("type", Json.str("object"))]))
      ]))
    ]);
  };

  public func handle(_context : ToolContext.ToolContext) : (
    _args : McpTypes.JsonValue,
    _auth : ?AuthTypes.AuthInfo,
    cb : (Result.Result<McpTypes.CallToolResult, McpTypes.HandlerError>) -> ()
  ) -> async () {
    func(args : McpTypes.JsonValue, _auth : ?AuthTypes.AuthInfo, cb : (Result.Result<McpTypes.CallToolResult, McpTypes.HandlerError>) -> ()) : async () {
      let appId = switch (Result.toOption(Json.getAsText(args, "appId"))) {
        case (?value) value;
        case (null) {
          return ToolContext.makeError("INVALID_INPUT: Missing 'appId'", cb);
        };
      };

      let adapter = _context.getAdapter();
      switch (await adapter.getAppDetails(appId)) {
        case (?app) {
          ToolContext.makeSuccess(Json.obj([("app", detailsJson(app))]), cb);
        };
        case (null) {
          ToolContext.makeError("NOT_FOUND: Unknown appId '" # appId # "'", cb);
        };
      };
    };
  };
}
