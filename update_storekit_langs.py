import json

path = "/Users/jannikschill/Documents/Garten-Simulation/Products.storekit"

with open(path, "r") as f:
    data = json.load(f)

# Locales from project rules
locales = ["de", "nl", "fr", "it", "ja", "ko", "pl", "pt", "es", "tr"]

if "products" in data:
    for product in data["products"]:
        for loc in locales:
            # check if exists
            exists = any(l.get("locale") == loc for l in product.get("localizations", []))
            if not exists:
                product["localizations"].append({
                    "description" : "",
                    "displayName" : product.get("referenceName", ""),
                    "locale" : loc
                })

if "subscriptionGroups" in data:
    for group in data["subscriptionGroups"]:
        if "subscriptions" in group:
            for sub in group["subscriptions"]:
                for loc in locales:
                    exists = any(l.get("locale") == loc for l in sub.get("localizations", []))
                    if not exists:
                        sub["localizations"].append({
                            "description" : "",
                            "displayName" : sub.get("referenceName", ""),
                            "locale" : loc
                        })

with open(path, "w") as f:
    json.dump(data, f, indent=2)

print("Updated storekit file")
