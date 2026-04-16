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

  func natOrNull(value : ?Nat) : Json.Json {
    switch (value) {
      case (?v) Json.int(v);
      case (null) Json.nullable();
    }
  };

  func boolOrNull(value : ?Bool) : Json.Json {
    switch (value) {
      case (?v) Json.bool(v);
      case (null) Json.nullable();
    }
  };

  public func config() : McpTypes.Tool = {
    name = "get_certificate_summary";
    title = ?"Get Certificate Summary";
    description = ?"Return the verification and certificate summary for an app.";
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
        ("certificate", Json.obj([("type", Json.str("object"))]))
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
      switch (await adapter.getCertificateSummary(appId)) {
        case (?cert) {
          ToolContext.makeSuccess(
            Json.obj([
              (
                "certificate",
                Json.obj([
                  ("tier", Json.str(cert.tier)),
                  ("buildReproducible", Json.bool(cert.buildReproducible)),
                  ("appInfoPassed", Json.bool(cert.appInfoPassed)),
                  ("toolsAndDependenciesPassed", boolOrNull(cert.toolsAndDependenciesPassed)),
                  ("dataSafetyPassed", boolOrNull(cert.dataSafetyPassed)),
                  ("gitCommit", textOrNull(cert.gitCommit)),
                  ("wasmHash", textOrNull(cert.wasmHash)),
                  ("canisterId", textOrNull(cert.canisterId)),
                  ("attestationCount", natOrNull(cert.attestationCount)),
                  ("certificateUrl", textOrNull(cert.certificateUrl)),
                  ("lastVerifiedAt", textOrNull(cert.lastVerifiedAt))
                ])
              )
            ]),
            cb,
          );
        };
        case (null) {
          ToolContext.makeError("NOT_FOUND: Unknown appId '" # appId # "'", cb);
        };
      };
    };
  };
}
