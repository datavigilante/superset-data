SELECT CAST(inserted_date AS DATE) 'Date Inserted',
    vendor_code 'Vendor',
    vendor_campaign_name 'Campaign name', 
    lead_status 'Lead Status', 
    vici_post_status 'Vici Post Status', 
    call_back_status 'Call Back Status',
    COUNT(DISTINCT post_request_id) requests
FROM dbo.post_request 
GROUP BY CAST(inserted_date AS DATE),
    vendor_code,
    vendor_campaign_name, 
    lead_status, 
    vici_post_status, 
    call_back_status