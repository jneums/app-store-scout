import Array "mo:base/Array";
import Result "mo:base/Result";
import Json "mo:json";

import McpTypes "mo:mcp-motoko-sdk/mcp/Types";
import AuthTypes "mo:mcp-motoko-sdk/auth/Types";

import ToolContext "ToolContext";
import AppStoreData "../AppStoreData";

module {
  public func config() : McpTypes.Tool = {
    name = "list_categories";
    title = ?"List Categories";
    description = ?"Return categories and counts.";
    payment = null;
    inputSchema = Json.obj([
      ("type", Json.str("object")),
      ("properties", Json.obj([]))
    ]);
    outputSchema = ?Json.obj([
      ("type", Json.str("object")),
      ("properties", Json.obj([
        ("categories", Json.obj([("type", Json.str("array")), ("items", Json.obj([("type", Json.str("object"))]))]))
      ]))
    ]);
  };

  public func handle(_context : ToolContext.ToolContext) : (
    _args : McpTypes.JsonValue,
    _auth : ?AuthTypes.AuthInfo,
    cb : (Result.Result<McpTypes.CallToolResult, McpTypes.HandlerError>) -> ()
  ) -> async () {
    func(_args : McpTypes.JsonValue, _auth : ?AuthTypes.AuthInfo, cb : (Result.Result<McpTypes.CallToolResult, McpTypes.HandlerError>) -> ()) : async () {
      let adapter = _context.getAdapter();
      let categories = await adapter.listCategories();
      ToolContext.makeSuccess(
        Json.obj([
          (
            "categories",
            Json.arr(Array.map<(Text, Nat), Json.Json>(categories, func(entry) {
              Json.obj([
                ("name", Json.str(entry.0)),
                ("count", Json.int(entry.1))
              ])
            }))
          )
        ]),
        cb,
      );
    };
  };
}
