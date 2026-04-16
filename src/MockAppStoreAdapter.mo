import AppStoreData "AppStoreData";
import AppStoreAdapter "AppStoreAdapter";

module {
  public func create() : AppStoreAdapter.AppStoreAdapter = {
    mode = #Mock;
    searchApps = func(listingQuery : AppStoreAdapter.ListingQuery) : async [AppStoreData.AppSummary] {
      AppStoreData.searchApps(listingQuery.searchText, listingQuery.category, listingQuery.verificationTier, listingQuery.tag, listingQuery.limit)
    };
    getAppDetails = func(appId : Text) : async ?AppStoreData.AppDetails {
      switch (AppStoreData.findApp(appId)) {
        case (?app) ?app.details;
        case (null) null;
      }
    };
    getCertificateSummary = func(appId : Text) : async ?AppStoreData.CertificateSummary {
      switch (AppStoreData.findApp(appId)) {
        case (?app) ?app.certificate;
        case (null) null;
      }
    };
    listRecentReleases = func(limit : Nat, category : ?Text) : async [AppStoreData.ReleaseSummary] {
      AppStoreData.listRecentReleases(limit, category)
    };
    listCategories = func() : async [(Text, Nat)] {
      AppStoreData.listCategories()
    };
    listTags = func(category : ?Text) : async [(Text, Nat)] {
      AppStoreData.listTags(category)
    };
    compareApps = func(appIds : [Text]) : async [AppStoreData.AppComparison] {
      AppStoreData.compareApps(appIds)
    };
    getSourceMeta = func() : AppStoreData.SourceMeta {
      AppStoreData.sourceMeta
    };
  };
}
