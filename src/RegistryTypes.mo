import Principal "mo:base/Principal";

module {
  public type ICRC16 = {
    #Array : [ICRC16];
    #Blob : Blob;
    #Bool : Bool;
    #Bytes : [Nat8];
    #Class : [ICRC16Property];
    #Float : Float;
    #Floats : [Float];
    #Int : Int;
    #Int16 : Int16;
    #Int32 : Int32;
    #Int64 : Int64;
    #Int8 : Int8;
    #Map : [(Text, ICRC16)];
    #Nat : Nat;
    #Nat16 : Nat16;
    #Nat32 : Nat32;
    #Nat64 : Nat64;
    #Nat8 : Nat8;
    #Nats : [Nat];
    #Option : ?ICRC16;
    #Principal : Principal;
    #Set : [ICRC16];
    #Text : Text;
    #ValueMap : [(ICRC16, ICRC16)];
  };

  public type ICRC16Property = {
    immutable : Bool;
    name : Text;
    value : ICRC16;
  };

  public type ICRC16Map = [(Text, ICRC16)];

  public type SecurityTier = {
    #Bronze;
    #Gold;
    #Silver;
    #Unranked;
  };

  public type AppListingStatus = {
    #External;
    #Pending;
    #Rejected : { reason : Text };
    #Verified;
  };

  public type AppVersionSummary = {
    created : Nat;
    security_tier : SecurityTier;
    status : AppListingStatus;
    version_string : Text;
    wasm_id : Text;
  };

  public type AppListing = {
    banner_url : Text;
    category : Text;
    deployment_type : Text;
    description : Text;
    icon_url : Text;
    latest_version : AppVersionSummary;
    name : Text;
    namespace : Text;
    publisher : Text;
    tags : [Text];
  };

  public type AppListingFilter = {
    #name : Text;
    #namespace : Text;
    #publisher : Text;
  };

  public type AppListingRequest = {
    filter : ?[AppListingFilter];
    prev : ?Text;
    take : ?Nat;
  };

  public type AppListingResponse = {
    #ok : [AppListing];
    #err : Text;
  };

  public type BuildInfo = {
    git_commit : ?Text;
    status : Text;
    failure_reason : ?Text;
    repo_url : ?Text;
  };

  public type DataSafetyInfo = {
    overall_description : Text;
    data_points : [ICRC16Map];
  };

  public type AttestationRecord = {
    audit_type : Text;
    auditor : Principal;
    metadata : ICRC16Map;
    timestamp : Int;
  };

  public type DivergenceRecord = {
    report : Text;
    metadata : ?ICRC16Map;
    timestamp : Int;
    reporter : Principal;
  };

  public type AuditRecord = {
    #Attestation : AttestationRecord;
    #Divergence : DivergenceRecord;
  };

  public type RunBountyResult = {
    metadata : ICRC16;
    result : { #Invalid; #Valid };
    trx_id : ?Nat;
  };

  public type ClaimRecord = {
    caller : Principal;
    claim_account : ?{ owner : Principal; subaccount : ?Blob };
    claim_id : Nat;
    claim_metadata : ICRC16Map;
    result : ?RunBountyResult;
    submission : ICRC16;
    time_submitted : Nat;
  };

  public type Bounty = {
    bounty_id : Nat;
    bounty_metadata : ICRC16Map;
    challenge_parameters : ICRC16;
    claimed : ?Nat;
    claimed_date : ?Nat;
    claims : [ClaimRecord];
    created : Nat;
    creator : Principal;
    payout_fee : Nat;
    timeout_date : ?Nat;
    token_amount : Nat;
    token_canister_id : Principal;
    validation_call_timeout : Nat;
    validation_canister_id : Principal;
  };

  public type AppVersionDetails = {
    audit_records : [AuditRecord];
    bounties : [Bounty];
    build_info : BuildInfo;
    created : Nat;
    data_safety : DataSafetyInfo;
    security_tier : SecurityTier;
    status : AppListingStatus;
    tools : [ICRC16Map];
    version_string : Text;
    wasm_id : Text;
  };

  public type AppDetailsResponse = {
    all_versions : [AppVersionSummary];
    banner_url : Text;
    category : Text;
    deployment_type : Text;
    description : Text;
    gallery_images : [Text];
    icon_url : Text;
    key_features : [Text];
    latest_version : AppVersionDetails;
    mcp_path : Text;
    name : Text;
    namespace : Text;
    publisher : Text;
    tags : [Text];
    why_this_app : Text;
  };

  public type AppStoreError = {
    #InternalError : Text;
    #NotFound : Text;
  };

  public type AppDetailsResult = {
    #ok : AppDetailsResponse;
    #err : AppStoreError;
  };

  public type VerificationRequest = {
    commit_hash : Blob;
    metadata : ICRC16Map;
    repo : Text;
    wasm_hash : Blob;
  };
}
