# Iran Firewall Address List for MikroTik

Keep a MikroTik address-list named **`IRAN`** up to date using a simple script and a weekly scheduler.  
This repo provides a ready-to-import `iran.rsc` containing the latest IP ranges, plus copy‑paste commands to automate updates.

> **What it does**
> 1) Clears old entries from `/ip firewall address-list list=IRAN`  
> 2) Downloads the fresh `iran.rsc` from GitHub  
> 3) Imports it into the `IRAN` address list  
> 4) Cleans up the temporary `iran.rsc` file  
> 5) (Optional) Schedules it to run every Monday at 05:00

---

## Requirements
- MikroTik RouterOS (v6 or v7).  
- Admin (write) access to the router.  
- Working DNS & internet access from the router (for the GitHub fetch).

---

## Quick Setup (script + scheduler)

Paste the following into the MikroTik **terminal**.

### 1) Create/replace the script
```rsc
/system script
:do { remove [find name="update-iran-ips"] } on-error={}
add name="update-iran-ips" policy=ftp,read,write,test,policy source={
    /ip firewall address-list
    :foreach i in=[find list=IRAN] do={ remove $i }

    /file
    :if ([:len [find name="iran.rsc"]] > 0) do={ remove [find name="iran.rsc"] }

    /tool fetch url="https://raw.githubusercontent.com/zalaghi/iran-fw-rsc/main/iran.rsc" dst-path=iran.rsc

    /import file-name=iran.rsc

    /file
    :if ([:len [find name="iran.rsc"]] > 0) do={ remove [find name="iran.rsc"] }
}
```

### 2) Run once now (optional)
```rsc
/system script run update-iran-ips
```

### 3) Schedule it for **Mondays at 05:00**
There are two ways—you only need **one** of them:

**A. Simple weekly schedule (add this on a Monday)**  
Runs at 05:00 every week on the same weekday you create it. If you add it on a **Monday**, it stays on Mondays thereafter.
```rsc
/system scheduler
:do { remove [find name="update-iran-ips-weekly"] } on-error={}
add name="update-iran-ips-weekly" start-time=05:00:00 interval=1w \
    on-event="/system script run update-iran-ips" \
    policy=ftp,read,write,test,policy comment="Run every Monday at 05:00"
```

**B. Explicit Monday start date (use if you’re not adding it on a Monday)**  
Replace the `start-date` with the date of the **next Monday** (format `mmm/DD/YYYY`, e.g., `aug/18/2025`).  
```rsc
/system scheduler
:do { remove [find name="update-iran-ips-weekly"] } on-error={}
add name="update-iran-ips-weekly" start-date=aug/18/2025 start-time=05:00:00 interval=1w \
    on-event="/system script run update-iran-ips" \
    policy=ftp,read,write,test,policy comment="Run every Monday at 05:00"
```

> **Tip:** After adding, run:
> ```rsc
> /system scheduler print detail where name="update-iran-ips-weekly"
> ```
> Check the `next-run` field to confirm it’s scheduled for the right **Monday 05:00**.

---

## Manual (Ad‑hoc) Update
If you prefer to update on demand without a scheduler, just run:
```rsc
/system script run update-iran-ips
```

---

## Verify It Worked
- Count entries:
  ```rsc
  /ip firewall address-list print count-only where list=IRAN
  ```
- Spot-check a few entries:
  ```rsc
  /ip firewall address-list print where list=IRAN
  ```

---

## Uninstall / Revert
Remove the scheduler and the script:
```rsc
/system scheduler remove [find name="update-iran-ips-weekly"]
/system script remove [find name="update-iran-ips"]
```
(Optional) Clear the `IRAN` list:
```rsc
/ip firewall address-list remove [find list=IRAN]
```

---

## Troubleshooting
- **Fetch fails (TLS / certificate error):** Keep RouterOS updated so its CA store is current.  
  If you still hit issues, verify router time and DNS are correct.
- **Name resolution fails:** Set working DNS servers (e.g. Cloudflare/Google) in `/ip dns`.
- **No entries after import:** Check the log for import errors and ensure `iran.rsc` downloaded successfully:
  ```rsc
  /file print where name="iran.rsc"
  ```

---

## Notes
- The script assumes the address list is named **`IRAN`** (case-sensitive).  
- You can change the list name by editing the occurrences of `IRAN` in the script.
- Scheduler day-of-week is derived from the **creation day** when using option **A** above.

---

## License
MIT
