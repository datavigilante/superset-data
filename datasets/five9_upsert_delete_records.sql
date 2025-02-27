SELECT 
    CAST(u.updated_date AS DATE) updated_date,     
    fu.request_id, 
    CASE 
        WHEN u.request_status = 'API_ERROR' THEN u.error 
        ELSE u.request_status 
    END request_status, 
    fu.load_status, 
    fu.request_type, 
    fu.file_name,
    count(*) requests
FROM five9.Upsert_ContactRecords u
JOIN dbo.file_upload fu 
    ON u.file_upload_id = fu.file_upload_id
GROUP BY 
    CAST(u.updated_date AS DATE),
    fu.request_id, 
    u.request_status, 
    fu.load_status, 
    CASE WHEN u.request_status = 'API_ERROR' THEN u.error ELSE u.request_status END,
    fu.request_type, 
    fu.file_name
UNION ALL
SELECT 
    CAST(u.updated_date AS DATE) updated_date, 
    fu.request_id, 
    CASE 
        WHEN u.request_status = 'REQUEST_ERROR' THEN u.error 
        ELSE u.request_status 
    END request_status,
    fu.load_status, 
    fu.request_type, 
    fu.file_name,
    COUNT(*) requests 
FROM five9.delete_ListRecords u
JOIN dbo.file_upload fu 
    ON u.file_upload_id = fu.file_upload_id
GROUP BY fu.request_id, 
    u.request_status, 
    fu.load_status, 
    CAST(u.updated_date AS DATE), 
    CASE WHEN u.request_status = 'REQUEST_ERROR' THEN u.error ELSE u.request_status END,
    fu.request_type,
    fu.file_name