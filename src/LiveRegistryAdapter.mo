import Array "mo:base/Array";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Order "mo:base/Order";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Prim "mo:prim";

import DateTime "mo:datetime/DateTime";

import AppStoreData "AppStoreData";
import AppStoreAdapter "AppStoreAdapter";
import McpRegistry "McpRegistry";
import McpOrchestrator "McpOrchestrator";
import RegistryTypes "RegistryTypes";

module {
  func tierToText(tier : RegistryTypes.SecurityTier) : Text {
    switch (tier) {
      case (#Gold) "gold";
      case (#Silver) "silver";
      case (#Bronze) "bronze";
      case (#Unranked) "unranked";
    }
  };

  func lower(text : Text) : Text {
    Text.map(text, func(c) {
      if (c >= 'A' and c <= 'Z') {
        Prim.charToLower(c)
      } else {
        c
      }
    })
  };

  func containsText(haystack : Text, needle : Text) : Bool {
    if (needle == "") { return true };
    Text.contains(lower(haystack), #text(lower(needle)))
  };

  func formatTimestampNanos(nanos : Nat) : Text {
    DateTime.DateTime(nanos).toText()
  };

  func formatTimestampIntNanos(nanos : Int) : Text {
    if (nanos < 0) {
      Int.toText(nanos) # "ns"
    } else {
      formatTimestampNanos(Int.abs(nanos))
    }
  };

  func listingMatches(listing : RegistryTypes.AppListing, listingQuery : AppStoreAdapter.ListingQuery) : Bool {
    let matchesQuery =
      listingQuery.searchText == "" or
      containsText(listing.name, listingQuery.searchText) or
      containsText(listing.description, listingQuery.searchText) or
      containsText(listing.publisher, listingQuery.searchText) or
      containsText(listing.namespace, listingQuery.searchText);

    let matchesCategory = switch (listingQuery.category) {
      case (null) true;
      case (?value) listing.category == value;
    };

    let matchesTier = switch (listingQuery.verificationTier) {
      case (null) true;
      case (?value) tierToText(listing.latest_version.security_tier) == value;
    };

    let matchesTag = switch (listingQuery.tag) {
      case (null) true;
      case (?value) Array.find<Text>(listing.tags, func(tag) = tag == value) != null;
    };

    matchesQuery and matchesCategory and matchesTier and matchesTag
  };

  func listingToSummary(listing : RegistryTypes.AppListing) : AppStoreData.AppSummary {
    {
      appId = listing.namespace;
      name = listing.name;
      publisher = listing.publisher;
      category = listing.category;
      shortDescription = listing.description;
      verificationTier = tierToText(listing.latest_version.security_tier);
      tags = listing.tags;
      mcpUrl = null;
      certificateUrl = ?certificateUrl(listing.namespace);
    }
  };

  func certificateUrl(namespace : Text) : Text {
    "https://prometheusprotocol.org/certificate/" # namespace
  };

  func textFromMetadata(metadata : RegistryTypes.ICRC16Map, key : Text) : ?Text {
    let found = Array.find<(Text, RegistryTypes.ICRC16)>(metadata, func(entry) = entry.0 == key);
    switch (found) {
      case (?( _, #Text(value) )) ?value;
      case (_) null;
    }
  };

  func mcpUrlFromAuditRecords(details : RegistryTypes.AppDetailsResponse) : ?Text {
    for (record in details.latest_version.audit_records.vals()) {
      switch (record) {
        case (#Attestation(attestation)) {
          switch (textFromMetadata(attestation.metadata, "mcp_url")) {
            case (?value) { return ?value };
            case (null) {};
          };
          switch (textFromMetadata(attestation.metadata, "mcpUrl")) {
            case (?value) { return ?value };
            case (null) {};
          };
        };
        case (#Divergence(_)) {};
      };
    };
    null
  };

  func canisterUrl(canisterId : Principal, path : Text) : Text {
    "https://" # Principal.toText(canisterId) # ".icp0.io" # path
  };

  func mcpUrl(details : RegistryTypes.AppDetailsResponse, orchestrator : McpOrchestrator.Service) : async ?Text {
    switch (mcpUrlFromAuditRecords(details)) {
      case (?value) ?value;
      case (null) {
        if (details.mcp_path == "") {
          return null;
        };
        let canisters = await orchestrator.get_canisters(details.namespace);
        if (canisters.size() == 0) {
          null
        } else {
          ?canisterUrl(canisters[0], details.mcp_path)
        }
      };
    }
  };

  func detailsToApp(details : RegistryTypes.AppDetailsResponse, resolvedMcpUrl : ?Text) : AppStoreData.AppDetails {
    {
      appId = details.namespace;
      name = details.name;
      publisher = details.publisher;
      category = details.category;
      shortDescription = details.description;
      verificationTier = tierToText(details.latest_version.security_tier);
      tags = details.tags;
      mcpUrl = resolvedMcpUrl;
      certificateUrl = ?certificateUrl(details.namespace);
      longDescription = ?details.description;
      whyThisApp = ?details.why_this_app;
      keyFeatures = details.key_features;
      repoUrl = details.latest_version.build_info.repo_url;
      iconUrl = if (details.icon_url == "") null else ?details.icon_url;
      bannerUrl = if (details.banner_url == "") null else ?details.banner_url;
      galleryImages = details.gallery_images;
      deploymentType = ?details.deployment_type;
      namespace = ?details.namespace;
      mcpPath = ?details.mcp_path;
      gitCommit = details.latest_version.build_info.git_commit;
      wasmPath = null;
      verificationChecklist = null;
    }
  };

  func detailsToCertificate(details : RegistryTypes.AppDetailsResponse, _verificationRequest : ?RegistryTypes.VerificationRequest) : AppStoreData.CertificateSummary {
    {
      tier = tierToText(details.latest_version.security_tier);
      buildReproducible = details.latest_version.build_info.status == "verified" or details.latest_version.build_info.status == "success";
      appInfoPassed = true;
      toolsAndDependenciesPassed = ?(details.latest_version.tools.size() > 0);
      dataSafetyPassed = ?(details.latest_version.data_safety.overall_description != "");
      gitCommit = details.latest_version.build_info.git_commit;
      wasmHash = ?details.latest_version.wasm_id;
      canisterId = null;
      attestationCount = ?details.latest_version.audit_records.size();
      certificateUrl = ?certificateUrl(details.namespace);
      lastVerifiedAt = if (details.latest_version.audit_records.size() > 0) ?formatTimestampIntNanos(switch (details.latest_version.audit_records[0]) {
        case (#Attestation(record)) record.timestamp;
        case (#Divergence(record)) record.timestamp;
      }) else null;
    }
  };

  func detailsToComparison(details : RegistryTypes.AppDetailsResponse) : AppStoreData.AppComparison {
    {
      appId = details.namespace;
      name = details.name;
      category = details.category;
      verificationTier = tierToText(details.latest_version.security_tier);
      publisher = details.publisher;
      tags = details.tags;
      repoUrl = details.latest_version.build_info.repo_url;
      keyStrengths = details.key_features;
      possibleRisks = if (details.latest_version.audit_records.size() == 0) ["no audit records yet"] else [];
    }
  };

  func fetchAllListings(registry : McpRegistry.Service, takePerPage : Nat) : async [RegistryTypes.AppListing] {
    var all : [RegistryTypes.AppListing] = [];
    var prev : ?Text = null;
    var keepGoing = true;

    while (keepGoing) {
      let response = await registry.get_app_listings({
        filter = null;
        prev = prev;
        take = ?takePerPage;
      });
      switch (response) {
        case (#ok(listings)) {
          if (listings.size() == 0) {
            keepGoing := false;
          } else {
            all := Array.append<RegistryTypes.AppListing>(all, listings);
            prev := ?listings[listings.size() - 1].namespace;
            if (listings.size() < takePerPage) {
              keepGoing := false;
            };
          };
        };
        case (#err(_)) {
          keepGoing := false;
        };
      };
    };

    all
  };

  public func create(canisterId : Principal) : AppStoreAdapter.AppStoreAdapter {
    let registry = McpRegistry.actorFor(canisterId);
    let orchestrator = McpOrchestrator.actorFor(Principal.fromText(McpOrchestrator.mainnetCanisterIdText));
    let sourceMeta : AppStoreData.SourceMeta = {
      source = "mcp_registry";
      sourceUpdatedAt = "live-query";
      fetchedAt = "runtime";
      freshness = "live-mainnet";
    };

    {
      mode = #LiveRegistry;
      searchApps = func(listingQuery : AppStoreAdapter.ListingQuery) : async [AppStoreData.AppSummary] {
        let listings = await fetchAllListings(registry, 100);
        let filtered = Array.filter<RegistryTypes.AppListing>(listings, func(listing) {
          listingMatches(listing, listingQuery) or (
            listingQuery.searchText != "" and Array.find<Text>(listing.tags, func(tag) = containsText(tag, listingQuery.searchText)) != null
          )
        });
        let limited = Array.subArray<RegistryTypes.AppListing>(filtered, 0, Nat.min(listingQuery.limit, filtered.size()));
        var summaries : [AppStoreData.AppSummary] = [];
        for (listing in limited.vals()) {
          switch (await registry.get_app_details_by_namespace(listing.namespace, null)) {
            case (#ok(details)) {
              let resolvedMcpUrl = await mcpUrl(details, orchestrator);
              summaries := Array.append<AppStoreData.AppSummary>(summaries, [{
                appId = listing.namespace;
                name = listing.name;
                publisher = listing.publisher;
                category = listing.category;
                shortDescription = listing.description;
                verificationTier = tierToText(listing.latest_version.security_tier);
                tags = listing.tags;
                mcpUrl = resolvedMcpUrl;
                certificateUrl = ?certificateUrl(listing.namespace);
              }]);
            };
            case (#err(_)) {
              summaries := Array.append<AppStoreData.AppSummary>(summaries, [listingToSummary(listing)]);
            };
          };
        };
        summaries
      };
      getAppDetails = func(appId : Text) : async ?AppStoreData.AppDetails {
        switch (await registry.get_app_details_by_namespace(appId, null)) {
          case (#ok(details)) {
            let resolvedMcpUrl = await mcpUrl(details, orchestrator);
            ?detailsToApp(details, resolvedMcpUrl)
          };
          case (#err(_)) null;
        }
      };
      getCertificateSummary = func(appId : Text) : async ?AppStoreData.CertificateSummary {
        switch (await registry.get_app_details_by_namespace(appId, null)) {
          case (#ok(details)) {
            let verificationRequest = await registry.get_verification_request(details.latest_version.wasm_id);
            ?detailsToCertificate(details, verificationRequest)
          };
          case (#err(_)) null;
        }
      };
      listRecentReleases = func(limit : Nat, category : ?Text) : async [AppStoreData.ReleaseSummary] {
        let listings = await fetchAllListings(registry, 100);
        let filtered = Array.filter<RegistryTypes.AppListing>(listings, func(listing) {
          switch (category) {
            case (null) true;
            case (?value) lower(listing.category) == lower(value);
          }
        });
        let sorted = Array.sort<RegistryTypes.AppListing>(filtered, func(a, b) {
          if (a.latest_version.created > b.latest_version.created) {
            #less
          } else if (a.latest_version.created < b.latest_version.created) {
            #greater
          } else {
            #equal
          }
        });
        let releases = Array.map<RegistryTypes.AppListing, AppStoreData.ReleaseSummary>(sorted, func(listing) {
          {
            appId = listing.namespace;
            name = listing.name;
            version = ?listing.latest_version.version_string;
            releasedAt = ?formatTimestampNanos(listing.latest_version.created);
            verificationStatus = ?(switch (listing.latest_version.status) {
              case (#Verified) "verified";
              case (#Pending) "pending";
              case (#Rejected(_)) "rejected";
            });
            tier = ?tierToText(listing.latest_version.security_tier);
          }
        });
        Array.subArray<AppStoreData.ReleaseSummary>(releases, 0, Nat.min(limit, releases.size()))
      };
      listCategories = func() : async [(Text, Nat)] {
        let listings = await fetchAllListings(registry, 100);
        var counts : [(Text, Nat)] = [];
        for (listing in listings.vals()) {
          let existing = Array.find<(Text, Nat)>(counts, func(entry) = lower(entry.0) == lower(listing.category));
          switch (existing) {
            case (?_) {
              counts := Array.map<(Text, Nat), (Text, Nat)>(counts, func(entry) {
                if (lower(entry.0) == lower(listing.category)) {
                  (entry.0, entry.1 + 1)
                } else {
                  entry
                }
              });
            };
            case (null) {
              counts := Array.append<(Text, Nat)>(counts, [(listing.category, 1)]);
            };
          };
        };
        counts
      };
      listTags = func(category : ?Text) : async [(Text, Nat)] {
        let listings = await fetchAllListings(registry, 100);
        var counts : [(Text, Nat)] = [];
        for (listing in listings.vals()) {
          let categoryMatches = switch (category) {
            case (null) true;
            case (?value) lower(listing.category) == lower(value);
          };
          if (categoryMatches) {
            for (tag in listing.tags.vals()) {
              let existing = Array.find<(Text, Nat)>(counts, func(entry) = lower(entry.0) == lower(tag));
              switch (existing) {
                case (?_) {
                  counts := Array.map<(Text, Nat), (Text, Nat)>(counts, func(entry) {
                    if (lower(entry.0) == lower(tag)) {
                      (entry.0, entry.1 + 1)
                    } else {
                      entry
                    }
                  });
                };
                case (null) {
                  counts := Array.append<(Text, Nat)>(counts, [(tag, 1)]);
                };
              };
            };
          };
        };
        counts
      };
      compareApps = func(appIds : [Text]) : async [AppStoreData.AppComparison] {
        var comparisons : [AppStoreData.AppComparison] = [];
        for (appId in appIds.vals()) {
          switch (await registry.get_app_details_by_namespace(appId, null)) {
            case (#ok(details)) {
              comparisons := Array.append<AppStoreData.AppComparison>(comparisons, [detailsToComparison(details)]);
            };
            case (#err(_)) {};
          }
        };
        comparisons
      };
      getSourceMeta = func() : AppStoreData.SourceMeta {
        sourceMeta
      };
    }
  };
}
