SELECT l.name 'Location',
    s.agent_type 'Agent Type',
    CASE r.active
        WHEN 1 THEN 'Active'
        ELSE 'Inactive'
    END 'Agent Status',
    r.rep_id 'Agent ID', 
    CONCAT(r.last_name, ', ', r.first_name) 'Agent',
    s.REVENUE_CLASS_DESC 'Account Type',
    s.SUB_STATUS_DESC 'Account Status',
    s.accounts 'Accounts'
FROM oe.nt_rep r
JOIN oe.nt_loc l
    ON l.id = r.loc
JOIN (
    SELECT 
        CASE
            WHEN ag.TYPE_DESC = 'Master' THEN 'Supervisor'
            WHEN ag.TYPE_DESC = 'Agent' THEN 'Agent'
        END agent_type, 
        REPLACE(ag.agent_code, '`', '') agent_code, 
        ac.revenue_class_desc,
        ac.SUB_STATUS_DESC, 
        COUNT(DISTINCT CONCAT(ac.customer_tkn, ac.customer_acct_tkn, ac.account_pkg_tkn)) AS accounts 
    FROM supply.ACCOUNT ac 
    JOIN supply.AGENT ag 
        ON ac.CUSTOMER_TKN = ag.CUSTOMER_TKN 
        AND ac.CUSTOMER_ACCT_TKN = ag.CUSTOMER_ACCT_TKN 
        AND ac.ACCOUNT_PKG_TKN = ag.ACCOUNT_PKG_TKN 
    WHERE AAA_END_DATE IS NULL 
    GROUP BY TYPE_DESC, ag.agent_code, 
        ac.REVENUE_CLASS_DESC,
        ac.SUB_STATUS_DESC 
) s
    ON s.agent_code = r.rep_id
