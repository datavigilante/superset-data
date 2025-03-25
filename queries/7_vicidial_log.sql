SELECT
    CAST(lo.call_date AS DATE) 'Call Date',
    lo.campaign_id 'Campaign ID',
    li.list_name 'List Name',
    lo.term_reason 'Term Reason',
    lo.processed 'Processed',
    vu.full_name 'Agent',
    lo.[status] 'Status Code',
    lo.phone_number 'Phone Number',
    vs.status_name 'Status Name',
    ISNULL(vs.status_name , lo.[status]) 'Status',
    pr.vendor_code 'Vendor Code',
    pr.vici_post_status 'VICI Post Status',
    pr.lead_status 'Lead Status',
    SUM(lo.called_count) 'Called Count',
    COUNT(DISTINCT lo.uniqueid) 'Calls'
FROM vd.vicidial_log lo
JOIN vd.vicidial_lists li 
    ON li.list_id = lo.list_id
    AND li.campaign_id = lo.campaign_id
JOIN vd.vicidial_users vu 
    ON vu.[user] = lo.[user]
JOIN vd.vicidial_campaigns vc
    ON vc.campaign_id = lo.campaign_id   
LEFT JOIN dbo.post_request pr
    ON pr.vendor_campaign_name = vc.campaign_name
    AND pr.target_vicidial_list_id = lo.list_id
    AND pr.phone_number = lo.phone_number
LEFT JOIN (
    SELECT vcs.campaign_id,
        vcs.status,
        vcs.status_name
    FROM vd.vicidial_campaign_statuses vcs
    UNION ALL
    SELECT 'N/A',
    vs.status,
        vs.status_name
    FROM vd.vicidial_statuses vs
) vs 
    ON vs.status = lo.status
    AND vs.campaign_id IN (lo.campaign_id, 'N/A')
WHERE lo.campaign_id = 'Ax_Duke1'
GROUP BY CAST(lo.call_date AS DATE),
    lo.campaign_id,
    li.list_name,
    lo.term_reason,
    lo.processed,
    vu.full_name,
    lo.status,
    lo.phone_number,
    vs.status_name,
    pr.vendor_code,
    pr.vici_post_status,
    pr.lead_status