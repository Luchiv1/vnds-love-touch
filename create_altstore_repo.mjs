import * as fs from "node:fs";
const appVersion = fs
    .readFileSync("app_version.txt", {
        encoding: "utf8",
        flag: "r",
    })
    .replace("\n", "");

const date = new Date().toISOString();
const repo = {
    name: "VNDS-LOVE-TOUCH!",
    featuredApps: ["me.octonezd.vnds"],
    identifier: "me.octonezd",
    apps: [
        {
            name: "VNDS-LOVE-TOUCH",
            bundleIdentifier: "me.octonezd.vnds",
            developerName: "OctoNezd",
            localizedDescription:
                "VNDS-LOVE-TOUCH is a fork of VNDS-LOVE designed to work with touchscreens",
            subtitle:
                "VNDS-LOVE-TOUCH is a fork of VNDS-LOVE designed to work with touchscreens",
            iconURL:
                "https://raw.githubusercontent.com/OctoNezd/VNDS-LOVE-TOUCH/refs/heads/main/icons/icon.png",
            tintColor: "FF9400",
            category: "social",
            versions: [
                {
                    version: appVersion,
                    date: date,
                    downloadURL: `https://github.com/OctoNezd/VNDS-LOVE-TOUCH/releases/download/${appVersion}/VNDS.ipa`,
                    size: 0,
                },
            ],
            appPermissions: {},
            // Sidestore: support
            // SideStore uses legacy repo format, see https://github.com/SideStore/SideStore/issues/314
            downloadURL: `https://github.com/OctoNezd/VNDS-LOVE-TOUCH/releases/download/${appVersion}/VNDS.ipa`,
            version: appVersion,
            versionDate: date,
            size: 0,
        },
    ],
};

fs.writeFileSync("altStoreManifest.json", JSON.stringify(repo));
