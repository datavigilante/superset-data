SELECT 
    DATETRUNC(DAY, r.inserted_date) inserted_date,    
    JSON_VALUE(r.raw_response, '$.file_name') file_name, 
    u.batch_name, 
    COALESCE(u.load_status, r.load_status) load_status, 
    r.request_id, 
    r.response error_message,
    u.phone,
    COUNT(DISTINCT r.response_raw_id) results,
    COUNT(DISTINCT u.file_upload_id) uploads
FROM dbo.response_raw r
LEFT JOIN (
    SELECT 
        ph.batch_name,
        ph.load_status,
        c.dnc_status,
        c.facility_code,
        ph.response_raw_id,
        ph.request_id,
        ph.file_upload_id,
        ph.phone 
    FROM dbo.file_upload u
    UNPIVOT
        (phone FOR phone_num IN
            (u.phone_number,
            u.phone_number2,
            u.phone_number3)
        ) AS ph
    LEFT JOIN dbo.contact c 
        ON c.phone = ph.phone
    GROUP BY 
        ph.batch_name,
        ph.load_status,
        c.dnc_status,
        c.facility_code,
        ph.response_raw_id,
        ph.request_id,
        ph.file_upload_id, 
        ph.phone
    UNION ALL
    SELECT 
        u.batch_name,
        u.load_status,
        NULL dnc_status,
        NULL facility_code,
        u.response_raw_id,
        u.request_id,
        u.file_upload_id,
        u.phone_number 
    FROM dbo.file_upload u
    WHERE u.phone_number IS NULL
        AND u.phone_number2 IS NULL
        AND u.phone_number3 IS NULL
) u 
    ON u.response_raw_id = r.response_raw_id
WHERE r.request_type IN ('add_to_contact_and_scrub')
GROUP BY 
    DATETRUNC(DAY, r.inserted_date), 
    JSON_VALUE(r.raw_response, '$.file_name'), 
    u.batch_name, 
    COALESCE(u.load_status, r.load_status), 
    r.request_id,
    r.response,
    u.phone