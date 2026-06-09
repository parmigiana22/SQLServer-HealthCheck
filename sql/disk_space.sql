SELECT DISTINCT
    vs.volume_mount_point,
    vs.logical_volume_name,
    CONVERT(decimal(18,2), vs.total_bytes / 1024.0 / 1024 / 1024) AS total_gb,
    CONVERT(decimal(18,2), vs.available_bytes / 1024.0 / 1024 / 1024) AS free_gb,
    CONVERT(decimal(18,2), (vs.available_bytes * 100.0) / NULLIF(vs.total_bytes, 0)) AS free_percent
FROM sys.master_files mf
CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) vs
ORDER BY free_percent ASC;
