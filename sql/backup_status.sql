SELECT
    d.name AS database_name,
    d.recovery_model_desc,
    MAX(b.backup_finish_date) AS last_full_backup,
    DATEDIFF(HOUR, MAX(b.backup_finish_date), GETDATE()) AS hours_since_last_full_backup
FROM sys.databases d
LEFT JOIN msdb.dbo.backupset b
    ON b.database_name = d.name
    AND b.type = 'D'
WHERE d.database_id > 4
GROUP BY d.name, d.recovery_model_desc
ORDER BY hours_since_last_full_backup DESC;
