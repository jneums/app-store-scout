import Array "mo:base/Array";
import Result "mo:base/Result";
import Json "mo:json";

import McpTypes "mo:mcp-motoko-sdk/mcp/Types";
import AuthTypes "mo:mcp-motoko-sdk/auth/Types";

import ToolContext "ToolContext";
import AppStoreData "../AppStoreData";

module {
  public func config() : McpTypes.Tool = {
    name = "list_tags";
    title = ?"List Tags";
    description = ?"Return tags and counts, optionally filtered by category.";
    payment = null;
    inputSchema = Json.obj([
      ("type", Json.str("object")),
      ("properties", Json.obj([
        ("category", Json.obj([("type", Json.str("string"))]))
      ]))
    ]);
    outputSchema = ?Json.obj([
      ("type", Json.str("object")),
      ("properties", Json.obj([
        ("tags", Json.obj([("type", Json.str("array")), ("items", Json.obj([("type", Json.str("object"))]))]))
      ]))
    ]);
  };

  public func handle(_context : ToolContext.ToolContext) : (
    _args : McpTypes.JsonValue,
    _auth : ?AuthTypes.AuthInfo,
    cb : (Result.Result<McpTypes.CallToolResult, McpTypes.HandlerError>) -> ()
  ) -> async () {
    func(args : McpTypes.JsonValue, _auth : ?AuthTypes.AuthInfo, cb : (Result.Result<McpTypes.CallToolResult, McpTypes.HandlerError>) -> ()) : async () {
      let category = Result.toOption(Json.getAsText(args, "category"));
      let adapter = _context.getAdapter();
      let tags = await adapter.listTags(category);
      ToolContext.makeSuccess(
        Json.obj([
          (
            "tags",
            Json.arr(Array.map<(Text, Nat), Json.Json>(tags, func(entry) {
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
