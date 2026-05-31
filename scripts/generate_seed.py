import uuid
cats = [
'Company Overview','Products & Quality Assurance','Catalog Feed & Product Data','Pricing & Commercial Terms','Branding & White Label Capabilities','Inventory Management','Fulfillment & Production Management','Shipping Management','Tracking & Shipment Visibility','Returns, Refunds & Warranty','Order Changes, Cancellations & Customer Requests','Customer Service','Service Level Agreements','Integrations & Technology','Reporting & Business Intelligence','Finance & Billing','Legal & Compliance','Security & Data Protection','Marketing & Brand Support','Launch Readiness','Post-Launch Support','Peak Season & Event Management']
reqs = {
'Company Overview':['Key contacts and escalation matrix','Business hours, weekends and holidays','Emergency communication process'],
'Products & Quality Assurance':['Quality control process and quality commitment','Damaged/defect rate KPI and review threshold','Personalization options','Branded gift box, gift card and insert options'],
'Catalog Feed & Product Data':['Product feed format and sample file','Mandatory product attributes','Image and media specifications'],
'Pricing & Commercial Terms':['Wholesale price list','Discount and volume structure','Price change notification process'],
'Branding & White Label Capabilities':['Neutral and branded packaging options','Packing slip and insert rules','Branding restrictions'],
'Inventory Management':['Inventory sync process','Out-of-stock handling','Safety stock rules'],
'Fulfillment & Production Management':['Production workflow','Production SLA by order type','Daily late order report covering 100% of late orders','Day 1 late supplier process','Day 2+ late process with automatic shipping upgrade','Peak season production capacity'],
'Shipping Management':['Shipping method matrix by country and factory','Shipping cost matrix','Carrier list and restrictions'],
'Tracking & Shipment Visibility':['Live tracking data access','Shipping incident alerts','Delivery exceptions process','ETA miss and shipping compensation process'],
'Returns, Refunds & Warranty':['Return eligibility rules','Damaged item claim process','Wrong item or missing item process','Refund, reorder and store credit process'],
'Order Changes, Cancellations & Customer Requests':['Cancellation window','Address change window','Shipping method upgrade process','Production cutoff rules'],
'Customer Service':['Supplier support channels','Supplier support SLA','Escalation process'],
'Service Level Agreements':['Production SLA','Shipping SLA','Support and escalation SLA','SLA breach compensation'],
'Integrations & Technology':['API documentation','Webhook support','Authentication and sandbox access','Technical contacts'],
'Reporting & Business Intelligence':['Available operational reports','Daily reporting automation','KPI definitions and export format'],
'Finance & Billing':['Invoice consolidation process','Compensation and credit note process','Payment terms and finance contacts'],
'Legal & Compliance':['Contract and terms','Data processing agreement','Compliance requirements'],
'Security & Data Protection':['Security certifications','Access control policy','Data retention policy'],
'Marketing & Brand Support':['Marketing assets availability','Brand approval workflow','Content usage restrictions'],
'Launch Readiness':['Testing plan','Go-live checklist','Launch blockers and dependencies','Final approval criteria'],
'Post-Launch Support':['Hypercare plan','Issue management process','Business review cadence'],
'Peak Season & Event Management':['Event capacity plan','Last safe shipping date matrix','Missed cutoff process','Daily orders-at-risk reporting','Event delivery compensation process']
}
print('-- Seed categories and requirements')
print("insert into workspaces (id, name, supplier_name, brand_name) values ('00000000-0000-0000-0000-000000000001','Lime&Lou x Jondo','Jondo','Lime&Lou'), ('00000000-0000-0000-0000-000000000002','Tenengroup x ShineOn','ShineOn','Tenengroup');")
for i,c in enumerate(cats,1):
    cid = str(uuid.uuid5(uuid.NAMESPACE_DNS, c))
    esc=c.replace("'","''")
    print(f"insert into categories (id, name, sort_order) values ('{cid}','{esc}',{i});")
    for j,title in enumerate(reqs[c],1):
        tid=str(uuid.uuid5(uuid.NAMESPACE_DNS, c+title))
        t=title.replace("'","''")
        need=(f"Please complete this section for {title.lower()}. Explain the current process, owner, SLA/KPI if applicable, and any limitations or risks.").replace("'","''")
        doc='Attach supporting document or sample if available.'
        for wid in ['00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000002']:
            print(f"insert into requirements (id, workspace_id, category_id, title, our_need, expected_document, status, sort_order) values ('{uuid.uuid4()}','{wid}','{cid}','{t}','{need}','{doc}','Waiting Supplier',{j});")
