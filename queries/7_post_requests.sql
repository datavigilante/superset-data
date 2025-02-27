    SELECT vendor_campaign_name, 
        lead_status, 
        vici_post_status, 
        call_back_status,
        MAX(post_request_id) post_request_id,
        COUNT(DISTINCT post_request_id) requests
    FROM dbo.post_request 
    GROUP BY vendor_campaign_name, 
        lead_status, 
        vici_post_status, 
        call_back_status