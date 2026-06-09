SELECT TOP 50
    j.name AS job_name,
    msdb.dbo.agent_datetime(h.run_date, h.run_time) AS run_datetime,
    h.step_id,
    h.step_name,
    h.message
FROM msdb.dbo.sysjobhistory h
JOIN msdb.dbo.sysjobs j ON h.job_id = j.job_id
WHERE h.run_status = 0
ORDER BY h.instance_id DESC;
