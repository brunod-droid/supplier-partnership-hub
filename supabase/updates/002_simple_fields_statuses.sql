-- Update portal to the simplified 4-field workflow:
-- Our need / Supplier answer / Final decision / Status

alter table requirements add column if not exists final_decision text;
alter table requirements alter column status type text using status::text;
alter table requirements alter column status set default 'Waiting Supplier';

update requirements set status = case
  when status in ('Supplier Replied') then 'Supplier Answered'
  when status in ('Internal Review','Need Clarification','Rejected','Blocked') then 'Discussion'
  when status in ('Approved') then 'Validated'
  else 'Waiting Supplier'
end
where status is distinct from case
  when status in ('Supplier Replied') then 'Supplier Answered'
  when status in ('Internal Review','Need Clarification','Rejected','Blocked') then 'Discussion'
  when status in ('Approved') then 'Validated'
  else 'Waiting Supplier'
end;

-- Core needs loaded from Bruno's supplier workbook notes.
update requirements set our_need = $need$We support customers 24/7 and deliveries run Monday to Saturday. We need a clear contact list and escalation matrix so we know exactly who to contact depending on the topic, urgency, time of day, weekend or holiday.$need$ where title = 'Key contacts and escalation matrix';
update requirements set our_need = $need$Please provide business hours, time zone, weekend coverage and holiday coverage. We also need to know if emergency support is available outside business hours.$need$ where title = 'Business hours, weekends and holidays';
update requirements set our_need = $need$For urgent production, shipping, tracking or technical incidents, we need a fast escalation process with clear response time, owner and backup contact.$need$ where title = 'Emergency communication process';

update requirements set our_need = $need$All products proposed by the supplier must be quality-assured before launch. We need the supplier's quality process and a written commitment on quality standards. If damaged/defect rate exceeds the agreed threshold, the process must be reviewed and compensation discussed.$need$ where title = 'Quality control process and quality commitment';
update requirements set our_need = $need$Please provide the current damaged/defect rate, how it is measured, and the review threshold. If Damaged > agreed %, the supplier must provide root cause, corrective action and compensation proposal.$need$ where title = 'Damaged/defect rate KPI and review threshold';
update requirements set our_need = $need$We need to understand precisely all customization options: text, names, photos, engraving, artwork, languages, limitations, production rules, preview process and error prevention controls.$need$ where title = 'Personalization options';
update requirements set our_need = $need$Please confirm if personalized gift boxes, gift cards, branded inserts or company-branded packaging are available. Provide price, process, lead time, minimum order quantity and required assets.$need$ where title = 'Branded gift box, gift card and insert options';

update requirements set our_need = $need$We need clear product feed and integration rules: format, sample file, update frequency, ownership and how errors are corrected.$need$ where title = 'Product feed format and sample file';
update requirements set our_need = $need$Please provide all mandatory product attributes needed for integration: SKU, title, description, variants, personalization fields, images, production time, dimensions, weight and shipping restrictions.$need$ where title = 'Mandatory product attributes';
update requirements set our_need = $need$Please provide image and media rules: format, size, naming, lifestyle images, mockups, thumbnails and any limitations by product type.$need$ where title = 'Image and media specifications';

update requirements set our_need = $need$Please provide the wholesale price list, including product cost, personalization cost, packaging cost, shipping cost and any additional operational fees.$need$ where title = 'Wholesale price list';
update requirements set our_need = $need$Please provide discount tiers, volume structure and any specific commercial agreements.$need$ where title = 'Discount and volume structure';
update requirements set our_need = $need$We need a clear process for price changes: notice period, approval process, effective date and impact on existing orders.$need$ where title = 'Price change notification process';

update requirements set our_need = $need$Our customer must experience our brand, not the supplier brand. Please describe neutral packaging, branded packaging, white-label options and all limitations.$need$ where title = 'Neutral and branded packaging options';
update requirements set our_need = $need$Please explain packing slip, inserts, gift card and marketing insert rules. Confirm what can be customized and what must be supplied by us.$need$ where title = 'Packing slip and insert rules';
update requirements set our_need = $need$Please list any branding restrictions, supplier branding that may appear, marketplace limitations or legal restrictions.$need$ where title = 'Branding restrictions';

update requirements set our_need = $need$We need reliable inventory visibility to prevent overselling. Please explain how inventory is synchronized, frequency, data format and failure handling.$need$ where title = 'Inventory sync process';
update requirements set our_need = $need$Please explain out-of-stock handling: when we are notified, how orders are blocked, how alternatives are proposed and how customers are protected.$need$ where title = 'Out-of-stock handling';
update requirements set our_need = $need$Please explain safety stock rules and how inventory is protected during peak periods.$need$ where title = 'Safety stock rules';

update requirements set our_need = $need$This is critical. We need the full production workflow from order reception to shipment, including checkpoints, responsibilities, cutoffs and exception handling.$need$ where title = 'Production workflow';
update requirements set our_need = $need$Please provide production SLA by order type: standard, personalized, peak season, reorders and urgent cases.$need$ where title = 'Production SLA by order type';
update requirements set our_need = $need$Every day, we need a report covering 100% of late orders, not 50% or 70%. The report must include order ID, delay reason, new deadline, shipping method and whether the order has been upgraded.$need$ where title = 'Daily late order report covering 100% of late orders';
update requirements set our_need = $need$Day 1 late: order must be flagged as Late Supplier, reason must be provided, and a plan to ship D+1 must be confirmed.$need$ where title = 'Day 1 late supplier process';
update requirements set our_need = $need$Day 2+ late: supplier must provide detailed reason, new confirmed deadline and automatic shipping upgrade at supplier expense. If the order already uses the most expensive method, shipping fees must be refunded.$need$ where title = 'Day 2+ late process with automatic shipping upgrade';
update requirements set our_need = $need$Please provide peak season capacity and how production is secured during Valentine’s Day, Mother’s Day, Father’s Day, Christmas, Black Friday and Cyber Monday.$need$ where title = 'Peak season production capacity';

update requirements set our_need = $need$We need a clear shipping method matrix by country, factory and speed, ordered from fastest to slowest with availability limitations.$need$ where title = 'Shipping method matrix by country and factory';
update requirements set our_need = $need$Please provide shipping costs by method, country, factory and any surcharge rules.$need$ where title = 'Shipping cost matrix';
update requirements set our_need = $need$Please provide all carriers used, restrictions, countries supported, factory availability and known limitations.$need$ where title = 'Carrier list and restrictions';

update requirements set our_need = $need$This is critical. We need live visibility on every shipment: tracking number, carrier, shipping method, current tracking status and ETA. API, feed or dashboard is preferred.$need$ where title = 'Live tracking data access';
update requirements set our_need = $need$Supplier must proactively notify us of any shipping issue that could put ETA at risk: weather, carrier delay, strike, hub backlog, customs issue or depot delay.$need$ where title = 'Shipping incident alerts';
update requirements set our_need = $need$Please provide process and notification rules for impossible delivery, wrong address, return to sender, lost package, business closed, customer unavailable and other exceptions.$need$ where title = 'Delivery exceptions process';
update requirements set our_need = $need$If an order is not delivered within ETA and the delay is not caused by the customer, we expect shipping compensation rules, including not charging/refunding shipping where applicable.$need$ where title = 'ETA miss and shipping compensation process';

update requirements set our_need = $need$Please confirm return eligibility rules for personalized and non-personalized products, aligned with TheoGrace/ShineOn and Lime&Lou/Jondo policies.$need$ where title = 'Return eligibility rules';
update requirements set our_need = $need$For damaged/defective items, we need the exact claim process: required photos, packaging photos, order ID, timeframe, approval flow, reorder/refund eligibility and compensation.$need$ where title = 'Damaged item claim process';
update requirements set our_need = $need$Please provide the process for wrong item, missing item and production mistake: evidence required, replacement timing, refund/reorder rule and supplier responsibility.$need$ where title = 'Wrong item or missing item process';
update requirements set our_need = $need$Please define refund, reorder, exchange and store credit process, including timelines and who pays in each scenario.$need$ where title = 'Refund, reorder and store credit process';

update requirements set our_need = $need$Cancellation is time-sensitive. Please confirm the cancellation window by brand/product type. Current expectation: personalized orders start production immediately; cancellation can be limited after the agreed cutoff.$need$ where title = 'Cancellation window';
update requirements set our_need = $need$Please confirm the address change window and exact process. Lime&Lou expectation: address changes possible up to 12 hours after order placement.$need$ where title = 'Address change window';
update requirements set our_need = $need$Please confirm the process and cutoff to upgrade shipping method after order placement, including price difference and operational limitations.$need$ where title = 'Shipping method upgrade process';
update requirements set our_need = $need$Please provide production cutoff rules for cancellation, address change, shipping method change and product modification.$need$ where title = 'Production cutoff rules';

update requirements set our_need = $need$We are your customer and need a clear supplier customer service process: channel, contacts, SLA, backup, escalation and communication format.$need$ where title = 'Supplier support channels';
update requirements set our_need = $need$Please provide response SLA for standard requests, urgent production issues, shipping incidents, technical issues and peak season.$need$ where title = 'Supplier support SLA';
update requirements set our_need = $need$Please provide escalation levels, contacts, timing and what qualifies as urgent.$need$ where title = 'Escalation process';

update requirements set our_need = $need$Please confirm the production SLA and how breaches are tracked, reported and compensated.$need$ where title = 'Production SLA';
update requirements set our_need = $need$Please confirm shipping SLA by method and country, including ETA calculation and carrier responsibility.$need$ where title = 'Shipping SLA';
update requirements set our_need = $need$Please confirm support and escalation SLA for daily operations and urgent incidents.$need$ where title = 'Support and escalation SLA';
update requirements set our_need = $need$Please define compensation rules when SLA is breached: shipping upgrade, refund of shipping, free order, credit note or other agreed compensation.$need$ where title = 'SLA breach compensation';

update requirements set our_need = $need$Please provide available APIs, documentation, environments and limitations.$need$ where title = 'API documentation';
update requirements set our_need = $need$Please confirm webhook support for order status, production status, tracking, cancellation and exceptions.$need$ where title = 'Webhook support';
update requirements set our_need = $need$Please provide authentication method, sandbox access and technical requirements.$need$ where title = 'Authentication and sandbox access';
update requirements set our_need = $need$Please provide technical owner, backup contact and escalation path.$need$ where title = 'Technical contacts';

update requirements set our_need = $need$Please list available reports: production, late orders, shipped orders, tracking, delivery performance, returns, defects, compensation and finance.$need$ where title = 'Available operational reports';
update requirements set our_need = $need$Daily reporting must be automated where possible, especially for late orders and shipments at risk.$need$ where title = 'Daily reporting automation';
update requirements set our_need = $need$Please define KPI calculations and export format for production SLA, late supplier, tracking, delivery ETA, returns, defects and compensation.$need$ where title = 'KPI definitions and export format';

update requirements set our_need = $need$Invoices must be consolidated and linked to orders. We need visibility on order cost, shipping, credits, compensation and specific agreements.$need$ where title = 'Invoice consolidation process';
update requirements set our_need = $need$Please explain how compensation and credit notes are created, approved and reconciled with invoices.$need$ where title = 'Compensation and credit note process';
update requirements set our_need = $need$Please provide payment terms, finance contacts and billing calendar.$need$ where title = 'Payment terms and finance contacts';

update requirements set our_need = $need$Please provide contract, terms and commercial conditions applicable to the partnership.$need$ where title = 'Contract and terms';
update requirements set our_need = $need$Please provide data processing agreement or data privacy documentation if personal/customer data is processed.$need$ where title = 'Data processing agreement';
update requirements set our_need = $need$Please provide all compliance requirements, certifications or restrictions that apply to the products and countries served.$need$ where title = 'Compliance requirements';
update requirements set our_need = $need$Please provide security certifications or security documentation relevant to systems, data and integrations.$need$ where title = 'Security certifications';
update requirements set our_need = $need$Please explain access controls, user permissions and how access is granted/revoked.$need$ where title = 'Access control policy';
update requirements set our_need = $need$Please provide data retention policy, deletion rules and backup rules.$need$ where title = 'Data retention policy';

update requirements set our_need = $need$Please provide available marketing assets, product images, videos, copy, mockups and usage rights.$need$ where title = 'Marketing assets availability';
update requirements set our_need = $need$Please explain brand approval workflow for assets, packaging, content and campaigns.$need$ where title = 'Brand approval workflow';
update requirements set our_need = $need$Please list content usage restrictions, brand restrictions and forbidden claims.$need$ where title = 'Content usage restrictions';

update requirements set our_need = $need$Please provide test plan before launch: orders, personalization, cancellation, address change, shipping, tracking, returns and finance.$need$ where title = 'Testing plan';
update requirements set our_need = $need$Please provide launch checklist and owner for each item.$need$ where title = 'Go-live checklist';
update requirements set our_need = $need$Please list blockers, dependencies and risks that can delay launch.$need$ where title = 'Launch blockers and dependencies';
update requirements set our_need = $need$Please confirm final go-live approval criteria for operations, tech, finance, customer service and reporting.$need$ where title = 'Final approval criteria';

update requirements set our_need = $need$Please provide hypercare plan after launch: duration, support coverage, escalation and daily monitoring.$need$ where title = 'Hypercare plan';
update requirements set our_need = $need$Please explain issue management process: ticketing, owner, severity, SLA, follow-up and resolution confirmation.$need$ where title = 'Issue management process';
update requirements set our_need = $need$Please propose business review cadence and topics: SLA, quality, compensation, finance, incidents and improvement plan.$need$ where title = 'Business review cadence';

update requirements set our_need = $need$During peak events (Valentine’s Day, Mother’s Day, Father’s Day, Christmas, Black Friday, Cyber Monday), all processes become critical. Please provide event capacity plan, staffing, monitoring and escalation.$need$ where title = 'Event capacity plan';
update requirements set our_need = $need$For each country and shipping method, provide last safe order/ship date to deliver on time for the event.$need$ where title = 'Last safe shipping date matrix';
update requirements set our_need = $need$If an order misses a supplier cutoff, supplier must upgrade shipping automatically until the last express cutoff. If the last express cutoff is missed, supplier must send the list immediately and provide free order + urgent method where applicable.$need$ where title = 'Missed cutoff process';
update requirements set our_need = $need$On the last delivery days before an event, supplier must provide a daily morning list of orders at risk based on tracking, with recovery plan and compensation status.$need$ where title = 'Daily orders-at-risk reporting';
update requirements set our_need = $need$For event orders at risk or delivered late, supplier must provide compensation rules including free shipping/credit and carrier claim process where applicable.$need$ where title = 'Event delivery compensation process';
