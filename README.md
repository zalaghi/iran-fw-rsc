# Create/replace the script
/system script
:do { remove [find name="update-iran-ips"] } on-error={}
add name="update-iran-ips" policy=read,write,test,policy source={
    /ip firewall address-list
    :foreach i in=[find list=IRAN] do={ remove $i }

    /file
    :if ([:len [find name="iran.rsc"]] > 0) do={ remove [find name="iran.rsc"] }

    /tool fetch url="https://raw.githubusercontent.com/zalaghi/iran-fw-rsc/main/iran.rsc" dst-path=iran.rsc

    /import file-name=iran.rsc

    /file
    :if ([:len [find name="iran.rsc"]] > 0) do={ remove [find name="iran.rsc"] }
}

# Create/replace the weekly scheduler (next Monday @ 05:00, then every 7 days)
/system scheduler
:do { remove [find name="update-iran-ips-weekly"] } on-error={}
add name="update-iran-ips-weekly" \
    start-date=aug/18/2025 start-time=05:00:00 interval=7d \
    on-event="/system script run update-iran-ips" \
    policy=ftp,read,write,test,policy comment="Run every Monday at 05:00"
