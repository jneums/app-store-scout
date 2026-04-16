import Array "mo:base/Array";
import Bool "mo:base/Bool";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

module {
  public type VerificationChecklist = {
    reproducibleBuild : Bool;
    appInfoComplete : Bool;
    toolsReviewed : Bool;
    dataSafetyReviewed : Bool;
  };

  public type AppSummary = {
    appId : Text;
    name : Text;
    publisher : Text;
    category : Text;
    shortDescription : Text;
    verificationTier : Text;
    tags : [Text];
    mcpUrl : ?Text;
    certificateUrl : ?Text;
  };

  public type AppDetails = {
    appId : Text;
    name : Text;
    publisher : Text;
    category : Text;
    shortDescription : Text;
    verificationTier : Text;
    tags : [Text];
    mcpUrl : ?Text;
    certificateUrl : ?Text;
    longDescription : ?Text;
    whyThisApp : ?Text;
    keyFeatures : [Text];
    repoUrl : ?Text;
    iconUrl : ?Text;
    bannerUrl : ?Text;
    galleryImages : [Text];
    deploymentType : ?Text;
    namespace : ?Text;
    mcpPath : ?Text;
    gitCommit : ?Text;
    wasmPath : ?Text;
    verificationChecklist : ?VerificationChecklist;
  };

  public type CertificateSummary = {
    tier : Text;
    buildReproducible : Bool;
    appInfoPassed : Bool;
    toolsAndDependenciesPassed : ?Bool;
    dataSafetyPassed : ?Bool;
    gitCommit : ?Text;
    wasmHash : ?Text;
    canisterId : ?Text;
    attestationCount : ?Nat;
    certificateUrl : ?Text;
    lastVerifiedAt : ?Text;
  };

  public type ReleaseSummary = {
    appId : Text;
    name : Text;
    version : ?Text;
    releasedAt : ?Text;
    verificationStatus : ?Text;
    tier : ?Text;
  };

  public type AppComparison = {
    appId : Text;
    name : Text;
    category : Text;
    verificationTier : Text;
    publisher : Text;
    tags : [Text];
    repoUrl : ?Text;
    keyStrengths : [Text];
    possibleRisks : [Text];
  };

  public type SourceMeta = {
    source : Text;
    sourceUpdatedAt : Text;
    fetchedAt : Text;
    freshness : Text;
  };

  public type AppRecord = {
    summary : AppSummary;
    details : AppDetails;
    certificate : CertificateSummary;
    release : ReleaseSummary;
    comparison : AppComparison;
  };

  public let sourceMeta : SourceMeta = {
    source = "mock-prometheus-app-store-index";
    sourceUpdatedAt = "2026-04-14T20:30:00Z";
    fetchedAt = "2026-04-14T20:45:00Z";
    freshness = "mock-static-seed";
  };

  public let apps : [AppRecord] = [
    {
      summary = {
        appId = "app-store-scout";
        name = "App Store Scout";
        publisher = "Prometheus Labs";
        category = "Discovery";
        shortDescription = "Search and compare Prometheus App Store listings.";
        verificationTier = "gold";
        tags = ["search", "discovery", "catalog"];
        mcpUrl = ?"https://app-store-scout.icp0.io/mcp";
        certificateUrl = ?"https://prometheusprotocol.org/certificates/app-store-scout";
      };
      details = {
        appId = "app-store-scout";
        name = "App Store Scout";
        publisher = "Prometheus Labs";
        category = "Discovery";
        shortDescription = "Search and compare Prometheus App Store listings.";
        verificationTier = "gold";
        tags = ["search", "discovery", "catalog"];
        mcpUrl = ?"https://app-store-scout.icp0.io/mcp";
        certificateUrl = ?"https://prometheusprotocol.org/certificates/app-store-scout";
        longDescription = ?"A discovery-focused MCP server that helps agents search, inspect, and compare apps in the Prometheus App Store.";
        whyThisApp = ?"Useful as a routing layer when an agent needs to pick the right downstream MCP app.";
        keyFeatures = ["keyword search", "certificate summaries", "side-by-side comparison"];
        repoUrl = ?"https://github.com/prometheus-protocol/app-store-scout";
        iconUrl = null;
        bannerUrl = null;
        galleryImages = [];
        deploymentType = ?"on-chain canister";
        namespace = ?"prometheus.discovery";
        mcpPath = ?"/mcp";
        gitCommit = ?"a1b2c3d4";
        wasmPath = ?".dfx/local/canisters/app_store_scout/app_store_scout.wasm";
        verificationChecklist = ?{
          reproducibleBuild = true;
          appInfoComplete = true;
          toolsReviewed = true;
          dataSafetyReviewed = true;
        };
      };
      certificate = {
        tier = "gold";
        buildReproducible = true;
        appInfoPassed = true;
        toolsAndDependenciesPassed = ?true;
        dataSafetyPassed = ?true;
        gitCommit = ?"a1b2c3d4";
        wasmHash = ?"0xaaa111";
        canisterId = ?"aaaaa-aa";
        attestationCount = ?5;
        certificateUrl = ?"https://prometheusprotocol.org/certificates/app-store-scout";
        lastVerifiedAt = ?"2026-04-10T12:00:00Z";
      };
      release = {
        appId = "app-store-scout";
        name = "App Store Scout";
        version = ?"0.1.0";
        releasedAt = ?"2026-04-12T18:00:00Z";
        verificationStatus = ?"verified";
        tier = ?"gold";
      };
      comparison = {
        appId = "app-store-scout";
        name = "App Store Scout";
        category = "Discovery";
        verificationTier = "gold";
        publisher = "Prometheus Labs";
        tags = ["search", "discovery", "catalog"];
        repoUrl = ?"https://github.com/prometheus-protocol/app-store-scout";
        keyStrengths = ["broad catalog coverage", "structured metadata", "certificate-aware"];
        possibleRisks = ["mock data in MVP", "depends on index freshness"];
      };
    },
    {
      summary = {
        appId = "verifier-watch";
        name = "Verifier Watch";
        publisher = "Prometheus Labs";
        category = "Security";
        shortDescription = "Track verification status and certificate drift across apps.";
        verificationTier = "silver";
        tags = ["verification", "security", "monitoring"];
        mcpUrl = ?"https://verifier-watch.icp0.io/mcp";
        certificateUrl = ?"https://prometheusprotocol.org/certificates/verifier-watch";
      };
      details = {
        appId = "verifier-watch";
        name = "Verifier Watch";
        publisher = "Prometheus Labs";
        category = "Security";
        shortDescription = "Track verification status and certificate drift across apps.";
        verificationTier = "silver";
        tags = ["verification", "security", "monitoring"];
        mcpUrl = ?"https://verifier-watch.icp0.io/mcp";
        certificateUrl = ?"https://prometheusprotocol.org/certificates/verifier-watch";
        longDescription = ?"A monitoring-oriented MCP server for auditors and agents that care about verification posture and changes over time.";
        whyThisApp = ?"Best when trust scoring matters more than broad discovery.";
        keyFeatures = ["certificate snapshots", "tier tracking", "release monitoring"];
        repoUrl = ?"https://github.com/prometheus-protocol/verifier-watch";
        iconUrl = null;
        bannerUrl = null;
        galleryImages = [];
        deploymentType = ?"on-chain canister";
        namespace = ?"prometheus.security";
        mcpPath = ?"/mcp";
        gitCommit = ?"b2c3d4e5";
        wasmPath = ?".dfx/local/canisters/app_store_scout/app_store_scout.wasm";
        verificationChecklist = ?{
          reproducibleBuild = true;
          appInfoComplete = true;
          toolsReviewed = true;
          dataSafetyReviewed = false;
        };
      };
      certificate = {
        tier = "silver";
        buildReproducible = true;
        appInfoPassed = true;
        toolsAndDependenciesPassed = ?true;
        dataSafetyPassed = ?false;
        gitCommit = ?"b2c3d4e5";
        wasmHash = ?"0xbbb222";
        canisterId = ?"bbbbb-bb";
        attestationCount = ?3;
        certificateUrl = ?"https://prometheusprotocol.org/certificates/verifier-watch";
        lastVerifiedAt = ?"2026-04-11T10:30:00Z";
      };
      release = {
        appId = "verifier-watch";
        name = "Verifier Watch";
        version = ?"0.2.1";
        releasedAt = ?"2026-04-13T09:00:00Z";
        verificationStatus = ?"verified";
        tier = ?"silver";
      };
      comparison = {
        appId = "verifier-watch";
        name = "Verifier Watch";
        category = "Security";
        verificationTier = "silver";
        publisher = "Prometheus Labs";
        tags = ["verification", "security", "monitoring"];
        repoUrl = ?"https://github.com/prometheus-protocol/verifier-watch";
        keyStrengths = ["trust-focused", "good for auditors", "release monitoring"];
        possibleRisks = ["narrower use case", "less useful for general browsing"];
      };
    },
    {
      summary = {
        appId = "promptbounties";
        name = "PromptBounties";
        publisher = "Bounty Guild";
        category = "Marketplace";
        shortDescription = "Discover prompt tasks, bounties, and reward opportunities.";
        verificationTier = "bronze";
        tags = ["bounties", "prompts", "marketplace"];
        mcpUrl = ?"https://promptbounties.icp0.io/mcp";
        certificateUrl = ?"https://prometheusprotocol.org/certificates/promptbounties";
      };
      details = {
        appId = "promptbounties";
        name = "PromptBounties";
        publisher = "Bounty Guild";
        category = "Marketplace";
        shortDescription = "Discover prompt tasks, bounties, and reward opportunities.";
        verificationTier = "bronze";
        tags = ["bounties", "prompts", "marketplace"];
        mcpUrl = ?"https://promptbounties.icp0.io/mcp";
        certificateUrl = ?"https://prometheusprotocol.org/certificates/promptbounties";
        longDescription = ?"A marketplace-style app where users and agents can find prompt engineering work and incentives.";
        whyThisApp = ?"Useful when the objective is work discovery rather than protocol research.";
        keyFeatures = ["bounty listing discovery", "prompt categories", "reward metadata"];
        repoUrl = ?"https://github.com/prometheus-protocol/promptbounties";
        iconUrl = null;
        bannerUrl = null;
        galleryImages = [];
        deploymentType = ?"on-chain canister";
        namespace = ?"prometheus.marketplace";
        mcpPath = ?"/mcp";
        gitCommit = ?"c3d4e5f6";
        wasmPath = null;
        verificationChecklist = ?{
          reproducibleBuild = false;
          appInfoComplete = true;
          toolsReviewed = true;
          dataSafetyReviewed = false;
        };
      };
      certificate = {
        tier = "bronze";
        buildReproducible = false;
        appInfoPassed = true;
        toolsAndDependenciesPassed = ?true;
        dataSafetyPassed = ?false;
        gitCommit = ?"c3d4e5f6";
        wasmHash = ?"0xccc333";
        canisterId = ?"ccccc-cc";
        attestationCount = ?2;
        certificateUrl = ?"https://prometheusprotocol.org/certificates/promptbounties";
        lastVerifiedAt = ?"2026-04-09T08:15:00Z";
      };
      release = {
        appId = "promptbounties";
        name = "PromptBounties";
        version = ?"0.5.0";
        releasedAt = ?"2026-04-08T15:45:00Z";
        verificationStatus = ?"partially_verified";
        tier = ?"bronze";
      };
      comparison = {
        appId = "promptbounties";
        name = "PromptBounties";
        category = "Marketplace";
        verificationTier = "bronze";
        publisher = "Bounty Guild";
        tags = ["bounties", "prompts", "marketplace"];
        repoUrl = ?"https://github.com/prometheus-protocol/promptbounties";
        keyStrengths = ["clear earning use case", "task-oriented", "good marketplace framing"];
        possibleRisks = ["lower verification tier", "more operational variability"];
      };
    },
    {
      summary = {
        appId = "governance-copilot";
        name = "Governance Copilot";
        publisher = "DAO Works";
        category = "Governance";
        shortDescription = "Summarize proposals and compare governance options.";
        verificationTier = "gold";
        tags = ["governance", "dao", "analysis"];
        mcpUrl = ?"https://governance-copilot.icp0.io/mcp";
        certificateUrl = ?"https://prometheusprotocol.org/certificates/governance-copilot";
      };
      details = {
        appId = "governance-copilot";
        name = "Governance Copilot";
        publisher = "DAO Works";
        category = "Governance";
        shortDescription = "Summarize proposals and compare governance options.";
        verificationTier = "gold";
        tags = ["governance", "dao", "analysis"];
        mcpUrl = ?"https://governance-copilot.icp0.io/mcp";
        certificateUrl = ?"https://prometheusprotocol.org/certificates/governance-copilot";
        longDescription = ?"A governance analysis server for proposal summaries, tradeoffs, and voting context.";
        whyThisApp = ?"Ideal when an agent needs structured help around proposals and treasury decisions.";
        keyFeatures = ["proposal summaries", "risk framing", "decision support"];
        repoUrl = ?"https://github.com/prometheus-protocol/governance-copilot";
        iconUrl = null;
        bannerUrl = null;
        galleryImages = [];
        deploymentType = ?"on-chain canister";
        namespace = ?"prometheus.governance";
        mcpPath = ?"/mcp";
        gitCommit = ?"d4e5f6g7";
        wasmPath = null;
        verificationChecklist = ?{
          reproducibleBuild = true;
          appInfoComplete = true;
          toolsReviewed = true;
          dataSafetyReviewed = true;
        };
      };
      certificate = {
        tier = "gold";
        buildReproducible = true;
        appInfoPassed = true;
        toolsAndDependenciesPassed = ?true;
        dataSafetyPassed = ?true;
        gitCommit = ?"d4e5f6g7";
        wasmHash = ?"0xddd444";
        canisterId = ?"ddddd-dd";
        attestationCount = ?6;
        certificateUrl = ?"https://prometheusprotocol.org/certificates/governance-copilot";
        lastVerifiedAt = ?"2026-04-12T07:20:00Z";
      };
      release = {
        appId = "governance-copilot";
        name = "Governance Copilot";
        version = ?"1.0.0";
        releasedAt = ?"2026-04-14T06:00:00Z";
        verificationStatus = ?"verified";
        tier = ?"gold";
      };
      comparison = {
        appId = "governance-copilot";
        name = "Governance Copilot";
        category = "Governance";
        verificationTier = "gold";
        publisher = "DAO Works";
        tags = ["governance", "dao", "analysis"];
        repoUrl = ?"https://github.com/prometheus-protocol/governance-copilot";
        keyStrengths = ["high trust", "clear decision support", "strong governance framing"];
        possibleRisks = ["domain-specific", "may need fresh proposal data adapters"];
      };
    },
    {
      summary = {
        appId = "dungeon-ops";
        name = "Dungeon Ops";
        publisher = "Guild Arcade";
        category = "Games";
        shortDescription = "Coordinate fantasy operations, quests, and team state.";
        verificationTier = "unranked";
        tags = ["game", "quests", "coordination"];
        mcpUrl = ?"https://dungeon-ops.icp0.io/mcp";
        certificateUrl = null;
      };
      details = {
        appId = "dungeon-ops";
        name = "Dungeon Ops";
        publisher = "Guild Arcade";
        category = "Games";
        shortDescription = "Coordinate fantasy operations, quests, and team state.";
        verificationTier = "unranked";
        tags = ["game", "quests", "coordination"];
        mcpUrl = ?"https://dungeon-ops.icp0.io/mcp";
        certificateUrl = null;
        longDescription = ?"A playful coordination server for game-like missions, parties, and quest execution.";
        whyThisApp = ?"Good demo material for fun, agentic multi-step workflows.";
        keyFeatures = ["quest coordination", "team state", "game flavor"];
        repoUrl = ?"https://github.com/prometheus-protocol/dungeon-ops";
        iconUrl = null;
        bannerUrl = null;
        galleryImages = [];
        deploymentType = ?"on-chain canister";
        namespace = ?"prometheus.games";
        mcpPath = ?"/mcp";
        gitCommit = ?"e5f6g7h8";
        wasmPath = null;
        verificationChecklist = null;
      };
      certificate = {
        tier = "unavailable";
        buildReproducible = false;
        appInfoPassed = false;
        toolsAndDependenciesPassed = null;
        dataSafetyPassed = null;
        gitCommit = ?"e5f6g7h8";
        wasmHash = null;
        canisterId = ?"eeeee-ee";
        attestationCount = ?0;
        certificateUrl = null;
        lastVerifiedAt = null;
      };
      release = {
        appId = "dungeon-ops";
        name = "Dungeon Ops";
        version = ?"0.0.9";
        releasedAt = ?"2026-04-07T11:10:00Z";
        verificationStatus = ?"unverified";
        tier = ?"unranked";
      };
      comparison = {
        appId = "dungeon-ops";
        name = "Dungeon Ops";
        category = "Games";
        verificationTier = "unranked";
        publisher = "Guild Arcade";
        tags = ["game", "quests", "coordination"];
        repoUrl = ?"https://github.com/prometheus-protocol/dungeon-ops";
        keyStrengths = ["fun demo value", "clear theme", "good for agent orchestration showcases"];
        possibleRisks = ["no certificate", "less suitable for trust-sensitive use cases"];
      };
    }
  ];

  func lower(text : Text) : Text {
    switch (text) {
      case ("Discovery") "discovery";
      case ("Security") "security";
      case ("Marketplace") "marketplace";
      case ("Governance") "governance";
      case ("Games") "games";
      case ("Prometheus Labs") "prometheus labs";
      case ("Bounty Guild") "bounty guild";
      case ("DAO Works") "dao works";
      case ("Guild Arcade") "guild arcade";
      case ("App Store Scout") "app store scout";
      case ("Verifier Watch") "verifier watch";
      case ("PromptBounties") "promptbounties";
      case ("Governance Copilot") "governance copilot";
      case ("Dungeon Ops") "dungeon ops";
      case ("gold") "gold";
      case ("silver") "silver";
      case ("bronze") "bronze";
      case ("unranked") "unranked";
      case ("search") "search";
      case ("discovery") "discovery";
      case ("catalog") "catalog";
      case ("verification") "verification";
      case ("security") "security";
      case ("monitoring") "monitoring";
      case ("bounties") "bounties";
      case ("prompts") "prompts";
      case ("marketplace") "marketplace";
      case ("governance") "governance";
      case ("dao") "dao";
      case ("analysis") "analysis";
      case ("game") "game";
      case ("quests") "quests";
      case ("coordination") "coordination";
      case (_) text;
    }
  };

  func containsIgnoreCase(haystack : Text, needle : Text) : Bool {
    if (needle == "") { return true };
    Text.contains(lower(haystack), #text(lower(needle)));
  };

  func textInArray(values : [Text], target : Text) : Bool {
    Array.find<Text>(values, func(value) = lower(value) == lower(target)) != null;
  };

  public func findApp(appId : Text) : ?AppRecord {
    Array.find<AppRecord>(apps, func(app) = app.summary.appId == appId);
  };

  public func searchApps(searchQuery : Text, category : ?Text, verificationTier : ?Text, tag : ?Text, limit : Nat) : [AppSummary] {
    let filtered = Array.filter<AppRecord>(apps, func(app) {
      let matchesQuery =
        searchQuery == "" or
        containsIgnoreCase(app.summary.name, searchQuery) or
        containsIgnoreCase(app.summary.shortDescription, searchQuery) or
        containsIgnoreCase(app.summary.publisher, searchQuery) or
        containsIgnoreCase(app.summary.category, searchQuery) or
        Array.find<Text>(app.summary.tags, func(t) = containsIgnoreCase(t, searchQuery)) != null;

      let matchesCategory = switch (category) {
        case (null) true;
        case (?value) lower(app.summary.category) == lower(value);
      };

      let matchesTier = switch (verificationTier) {
        case (null) true;
        case (?value) lower(app.summary.verificationTier) == lower(value);
      };

      let matchesTag = switch (tag) {
        case (null) true;
        case (?value) textInArray(app.summary.tags, value);
      };

      matchesQuery and matchesCategory and matchesTier and matchesTag;
    });

    let summaries = Array.map<AppRecord, AppSummary>(filtered, func(app) = app.summary);
    Array.subArray<AppSummary>(summaries, 0, Nat.min(limit, summaries.size()));
  };

  public func listRecentReleases(limit : Nat, category : ?Text) : [ReleaseSummary] {
    let filtered = Array.filter<AppRecord>(apps, func(app) {
      switch (category) {
        case (null) true;
        case (?value) lower(app.summary.category) == lower(value);
      }
    });

    let sorted = Array.sort<AppRecord>(filtered, func(a, b) {
      switch (Text.compare(switch (b.release.releasedAt) { case (?v) v; case null "" }, switch (a.release.releasedAt) { case (?v) v; case null "" })) {
        case (#less) #less;
        case (#equal) #equal;
        case (#greater) #greater;
      }
    });

    let releases = Array.map<AppRecord, ReleaseSummary>(sorted, func(app) = app.release);
    Array.subArray<ReleaseSummary>(releases, 0, Nat.min(limit, releases.size()));
  };

  func incrementCount(counts : [(Text, Nat)], name : Text, ignoreCase : Bool) : [(Text, Nat)] {
    let existing = Array.find<(Text, Nat)>(counts, func(entry) {
      if (ignoreCase) {
        lower(entry.0) == lower(name)
      } else {
        entry.0 == name
      }
    });

    switch (existing) {
      case (?_) {
        Array.map<(Text, Nat), (Text, Nat)>(counts, func(entry) {
          let same = if (ignoreCase) { lower(entry.0) == lower(name) } else { entry.0 == name };
          if (same) {
            (entry.0, entry.1 + 1)
          } else {
            entry
          }
        })
      };
      case (null) {
        Array.append<(Text, Nat)>(counts, [(name, 1)])
      };
    }
  };

  public func listCategories() : [(Text, Nat)] {
    var counts : [(Text, Nat)] = [];
    for (app in apps.vals()) {
      counts := incrementCount(counts, app.summary.category, false);
    };
    counts;
  };

  public func listTags(category : ?Text) : [(Text, Nat)] {
    var counts : [(Text, Nat)] = [];
    for (app in apps.vals()) {
      let categoryMatches = switch (category) {
        case (null) true;
        case (?value) lower(app.summary.category) == lower(value);
      };
      if (categoryMatches) {
        for (tag in app.summary.tags.vals()) {
          counts := incrementCount(counts, tag, true);
        };
      };
    };
    counts;
  };

  public func compareApps(appIds : [Text]) : [AppComparison] {
    let found = Array.mapFilter<Text, AppComparison>(appIds, func(appId) {
      switch (findApp(appId)) {
        case (?app) ?app.comparison;
        case (null) null;
      }
    });
    found;
  };
}
