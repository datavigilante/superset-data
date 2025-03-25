SELECT l.name 'Location',
    s.supervisor 'Supervisor',
    CASE r.active
        WHEN 1 THEN 'Active'
        ELSE 'Inactive'
    END 'Status',
    r.rep_id 'Rep ID', 
    CONCAT(r.last_name, ', ', r.first_name) 'Name', 
    s.residential 'Residential', 
    s.small_commercial 'Small Commercial',
    s.residential_commission 'Residential Commission',
    s.commercial_commission 'Commercial Commission',
    s.residential_commission + commercial_commission 'Total Commission'
FROM oe.nt_rep r
JOIN oe.nt_loc l
    ON l.id = r.loc
JOIN (
    SELECT piv.supervisor,
        piv.agent_code,
        ISNULL(piv.Residential, 0) residential, 
        ISNULL(piv.[Small Commercial], 0) small_commercial,
        ISNULL(CASE
            WHEN piv.supervisor = 'No' AND piv.AGENT_CODE = 8979 THEN piv.Residential * 0.05
            WHEN piv.supervisor = 'No' AND piv.AGENT_CODE <> 8979 THEN piv.Residential * 0.125
            WHEN piv.supervisor = 'Yes' THEN piv.Residential * 0.05
        END, 0) residential_commission,
        ISNULL(CASE 
            WHEN piv.supervisor = 'No' AND piv.AGENT_CODE = 8979 THEN piv.[Small Commercial] * 0.2
            WHEN piv.supervisor = 'No' AND piv.AGENT_CODE <> 8979 THEN piv.[Small Commercial] * 0.35
            WHEN piv.supervisor = 'Yes' THEN piv.[Small Commercial] * 0.15
        END, 0) commercial_commission  
    FROM (	
        SELECT 
            CASE
                WHEN ag.TYPE_DESC = 'Master' THEN 'Yes'
                WHEN ag.TYPE_DESC = 'Agent' THEN 'No'
            END supervisor, 
            REPLACE(ag.agent_code, '`', '') agent_code, 
            revenue_class_desc, 
            count(*) AS c 
        FROM supply.ACCOUNT ac 
        JOIN supply.AGENT ag 
            ON ac.CUSTOMER_TKN = ag.CUSTOMER_TKN 
            AND ac.CUSTOMER_ACCT_TKN = ag.CUSTOMER_ACCT_TKN 
            AND ac.ACCOUNT_PKG_TKN = ag.ACCOUNT_PKG_TKN 
        WHERE ac.SUB_STATUS_DESC = 'Flowing'  
            AND AAA_END_DATE IS NULL 
        GROUP BY TYPE_DESC, agent_code, REVENUE_CLASS_DESC 
    ) src
    PIVOT
    (
        SUM(c)
        FOR REVENUE_CLASS_DESC IN ([Residential], [Small Commercial])
    ) piv
) s
    ON s.agent_code = r.rep_id
WHERE r.rep_id NOT IN (7000, 9000) 
UNION ALL
SELECT l.name location,
    s.supervisor, 
    CASE r.active
        WHEN 1 THEN 'Active'
        ELSE 'Inactive'
    END status,
    '9000' rep_id, 
    'Arthurs, Mariah' name, 
    SUM(s.residential) residential, 
    SUM(s.small_commercial) small_commercial,
    SUM(s.residential) * 0.02 residential_commission,
    SUM(s.small_commercial) * 0.0475 commercial_commission,
    (SUM(s.residential) * 0.02) + SUM(s.small_commercial) * 0.0475 total_commision
FROM oe.nt_rep r
JOIN oe.nt_loc l
    ON l.id = r.loc
JOIN (
    SELECT 'Other' supervisor,
        piv.agent_code,
        ISNULL(piv.Residential, 0) residential, 
        ISNULL(piv.[Small Commercial], 0) small_commercial
    FROM (	
        SELECT 
            CASE
                WHEN ag.TYPE_DESC = 'Master' THEN 'Yes'
                WHEN ag.TYPE_DESC = 'Agent' THEN 'No'
            END supervisor, 
            REPLACE(ag.agent_code, '`', '') agent_code, 
            revenue_class_desc, 
            count(*) AS c 
        FROM supply.ACCOUNT ac 
        JOIN supply.AGENT ag 
            ON ac.CUSTOMER_TKN = ag.CUSTOMER_TKN 
            AND ac.CUSTOMER_ACCT_TKN = ag.CUSTOMER_ACCT_TKN 
            AND ac.ACCOUNT_PKG_TKN = ag.ACCOUNT_PKG_TKN 
        WHERE ac.SUB_STATUS_DESC = 'Flowing'  
            AND ag.AAA_END_DATE IS NULL
            AND ag.AAA_START_DATE >= '2019-05-01' 
        GROUP BY TYPE_DESC, agent_code, REVENUE_CLASS_DESC 
    ) src
    PIVOT
    (
        SUM(c)
        FOR REVENUE_CLASS_DESC IN ([Residential], [Small Commercial])
    ) piv
) s
    ON s.agent_code = r.rep_id
WHERE r.rep_id NOT IN (7000)
GROUP BY l.name,
    s.supervisor,
    r.active