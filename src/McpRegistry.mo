import Principal "mo:base/Principal";
import RegistryTypes "RegistryTypes";

module {
  public let mainnetCanisterIdText : Text = "grhdx-gqaaa-aaaai-q32va-cai";

  public type Service = actor {
    get_app_listings : shared query (RegistryTypes.AppListingRequest) -> async RegistryTypes.AppListingResponse;
    get_app_details_by_namespace : shared query (Text, ?Text) -> async RegistryTypes.AppDetailsResult;
    get_verification_request : shared query (Text) -> async ?RegistryTypes.VerificationRequest;
  };

  public func actorFor(canisterId : Principal) : Service {
    actor (Principal.toText(canisterId)) : Service
  };
}
