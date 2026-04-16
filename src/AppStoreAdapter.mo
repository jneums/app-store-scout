import AppStoreData "AppStoreData";

module {
  public type AdapterMode = {
    #Mock;
    #LiveRegistry;
  };

  public type ListingQuery = {
    searchText : Text;
    category : ?Text;
    verificationTier : ?Text;
    tag : ?Text;
    limit : Nat;
  };

  public type AppStoreAdapter = {
    mode : AdapterMode;
    searchApps : (ListingQuery) -> async [AppStoreData.AppSummary];
    getAppDetails : (Text) -> async ?AppStoreData.AppDetails;
    getCertificateSummary : (Text) -> async ?AppStoreData.CertificateSummary;
    listRecentReleases : (Nat, ?Text) -> async [AppStoreData.ReleaseSummary];
    listCategories : () -> async [(Text, Nat)];
    listTags : (?Text) -> async [(Text, Nat)];
    compareApps : ([Text]) -> async [AppStoreData.AppComparison];
    getSourceMeta : () -> AppStoreData.SourceMeta;
  };

  public type AdapterResolver = () -> AppStoreAdapter;
}
