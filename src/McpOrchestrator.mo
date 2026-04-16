import Principal "mo:base/Principal";

module {
  public let mainnetCanisterIdText : Text = "ez54s-uqaaa-aaaai-q32za-cai";

  public type Service = actor {
    get_canisters : shared query (Text) -> async [Principal];
  };

  public func actorFor(canisterId : Principal) : Service {
    actor (Principal.toText(canisterId)) : Service
  };
}
