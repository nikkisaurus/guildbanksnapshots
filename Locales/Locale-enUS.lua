local addonName = ...
local addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)
LibStub("LibAddonUtils-1.0"):Embed(addon)




L["Age Measure"] = true
L["Age Unit"] = true
L["Alert scan progress"] = true
L["Analyze"] = true
L["Analyze Scan"] = true
L["Approximate"] = true
L["Auto Cleanup"] = true
L["Auto Scan"] = true
L["Cancel"] = true
L["Character"] = true
L["Cleanup"] = true
L["Cleanup finished."] = true
L["Comma"] = true
L["Confirm Deletions"] = true
L["Current Total"] = true
L["Date Format"] = true
L["Date Type"] = true
L["day"] = true
L["days"] = true
L["Default"] = true
L["Default Guild"] = true
L["Delay"] = true
L["Delete corrupted scans"] = true
L["Delete scans older than"] = true
L["Delete Scan"] = true
L["Deposits"] = true
L["Deselect All"] = true
L["Enable"] = true
L["Enable frequency limit"] = true
L["Export"] = true
L["Export Scan"] = true
L["Frequency Measure"] = true
L["Frequency Unit"] = true
L["Guild"] = true
L["Guild Format"] = true
L["Help"] = true
L["hour"] = true
L["hours"] = true
L["Item"] = true
L["Loading scans"] = true
L["Master"] = true
L["minute"] = true
L["minutes"] = true
L["Money"] = true
L["Money Tab"] = true
L["month"] = true
L["months"] = true
L["Net"] = true
L["No changes detected."] = true
L["Pipe"] = true
L["Preferences"] = true
L["Processing"] = true
L["Repairs"] = true
L["Review"] = true
L["Review after auto scan"] = true
L["Review after scan"] = true
L["Review Path"] = true
L["Scan"] = true
L["Scan failed."] = true
L["Scan finished."] = true
L["Scanning"] = true
L["Scans"] = true
L["Select All"] = true
L["Select Item"] = true
L["Select Scans"] = true
L["Semicolon"] = true
L["Settings"] = true
L["Start"] = true
L["Summary"] = true
L["Tab"] = true
L["Tabs"] = true
L["Type"] = true
L["Unknown"] = true
L["week"] = true
L["weeks"] = true
L["Withdrawals"] = true




L.addon = "Guild Bank Snapshots"
L.BankClosedError = "Please open your guild bank frame and try again."
L.ConfirmDeleteScan = "Are you sure you want to delete this scan?"
L.CorruptScan = "Scan corrupt. Please try again."




L.ScanDelayDescription = "Determines the amount of time between querying the guild bank transaction logs and saving the scan. Increasing this delay may help reduce corrupt scans."
L.ScanReviewDescription = "Shows the review frame after manually scanning the bank."
L.ScanReviewPathDescription = "Determines which panel is opened when the review frame is shown."


L.ScanAutoAlertDescription = "Displays a message with the status of auto scans."
L.ScanAutoReviewDescription = "Shows the review frame after the bank auto scans."
L.ScanAutoFrequncyEnabledDescription = "Limits the number of auto scans allowed to run."
L.ScanAutoFrequencyDescription = "Determines the frequency at which auto scans are allowed to run."


L.ScanAutoCleanupEnabledDescription = "Automatically deletes scans older than the specified time frame."
L.ScanAutoCleanupDescription = "Determines how far back scans are saved. For example, if this is set to 30 days, all scans older than 30 days will be deleted."
L.ConfirmCleanup = "Are you sure you want to clean up your database? This action is irreversible. Be sure to backup or export your settings."


L.DateTypeDescription = "Determines whether dates are shown as presented in the guild bank transaction log or approximate dates based on the scan time."
L.DefaultGuildDescription = "Sets the default guild to load when reviewing or analyzing a scan."
L.GuildFormatDescription = "%g = guild name\n%r = realm name\n%f = faction\n%F = shortened faction"
L.ConfirmDeletionsDescription = "Prompt for confirmation when deleting scans via the review frame. Note: this does not apply to auto cleanup deletions."
