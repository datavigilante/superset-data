SELECT
    CAST(r.inserted_date AS DATE) inserted_date,    
    JSON_VALUE(r.raw_response, '$.file_name') file_name, 
    u2.batch_name, 
    COALESCE(u2.load_status, r.load_status) load_status, 
    r.request_id, 
    r.response error_message,
    u2.phone,
    u2.file_name file_name2,
    u2.request_type,
    u2.updated_date,
    u2.request_status,
    COUNT(DISTINCT r.response_raw_id) results,
    COUNT(DISTINCT u2.file_upload_id) uploads
FROM dbo.response_raw r
LEFT JOIN (
    SELECT u.*,
        CASE u.request_type
            WHEN 'add_to_contact_and_scrub' THEN uc.updated_date
            WHEN 'DELETE_RECORDS_FROM_LIST' THEN dl.updated_date
            ELSE NULL
        END updated_date,
        CASE u.request_type
            WHEN 'add_to_contact_and_scrub' THEN uc.request_status
            WHEN 'DELETE_RECORDS_FROM_LIST' THEN dl.request_status
            ELSE u.request_type    
       END request_status
    FROM (
        SELECT 
            ph.batch_name,
            ph.load_status,
            c.dnc_status,
            c.facility_code,
            ph.response_raw_id,
            ph.request_id,
            ph.file_upload_id,
            ph.phone,
            ph.file_name,
            ph.request_type
        FROM dbo.file_upload u
        UNPIVOT
            (phone FOR phone_num IN
                (u.phone_number,
                u.phone_number2,
                u.phone_number3)
            ) AS ph
        JOIN dbo.contact c 
            ON c.phone = ph.phone
        GROUP BY 
            ph.batch_name,
            ph.load_status,
            c.dnc_status,
            c.facility_code,
            ph.response_raw_id,
            ph.request_id,
            ph.file_upload_id, 
            ph.phone,
            ph.file_name,
            ph.request_type
        UNION ALL
        SELECT 
            u.batch_name,
            u.load_status,
            NULL dnc_status,
            NULL facility_code,
            u.response_raw_id,
            u.request_id,
            u.file_upload_id,
            u.phone_number,
            u.file_name,
            u.request_type 
        FROM dbo.file_upload u
        WHERE u.phone_number IS NULL
            AND u.phone_number2 IS NULL
            AND u.phone_number3 IS NULL
    ) u
    LEFT JOIN ( 
        SELECT file_upload_id, CAST(updated_date AS DATE) updated_date, 
            CASE WHEN request_status = 'API_ERROR' THEN error ELSE request_status END request_status 
        FROM five9.Upsert_ContactRecords
        GROUP BY file_upload_id, CAST(updated_date AS DATE), 
            CASE WHEN request_status = 'API_ERROR' THEN error ELSE request_status END 
    ) uc
      ON uc.file_upload_id = u.file_upload_id
    LEFT JOIN ( 
        SELECT file_upload_id, CAST(updated_date AS DATE) updated_date, 
            CASE WHEN request_status = 'REQUEST_ERROR' THEN error ELSE request_status END request_status 
        FROM five9.delete_ListRecords
        GROUP BY file_upload_id, CAST(updated_date AS DATE), 
            CASE WHEN request_status = 'REQUEST_ERROR' THEN error ELSE request_status END 
    ) dl
      ON dl.file_upload_id = u.file_upload_id
) u2 
    ON u2.response_raw_id = r.response_raw_id
WHERE r.inserted_date >= CONVERT(DATETIME, '2025-02-26T00:00:00.000', 126)
GROUP BY 
    CAST(r.inserted_date AS DATE), 
    JSON_VALUE(r.raw_response, '$.file_name'), 
    u2.batch_name, 
    COALESCE(u2.load_status, r.load_status), 
    r.request_id,
    r.response,
    u2.phone,
    u2.file_name,
    u2.request_type,
    u2.updated_date,
    u2.request_status