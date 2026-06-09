SELECT
    name AS database_name,
    state_desc,
    recovery_model_desc,
    compatibility_level,
    create_date,
    user_access_desc,
    is_read_only,
    is_auto_close_on,
    is_auto_shrink_on
FROM sys.databases
ORDER BY name;
