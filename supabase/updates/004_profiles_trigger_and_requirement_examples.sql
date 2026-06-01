-- 004 - Profiles trigger + clearer supplier-facing needs and examples
-- Run this in Supabase SQL Editor. It is safe to run multiple times.

-- 1) Create an automatic profile row when a user is added in Supabase Auth.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name, role)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)), 'supplier')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- Note: New users will default to role = supplier. Change role to admin/internal in public.profiles when needed.

-- 2) Add example field used by the portal.
alter table public.requirements add column if not exists example_response text;

-- 3) Update all existing requirement lines with clearer Our Need text and example response.
update public.requirements
set our_need = $txt$What we need
Please provide available APIs, documentation, endpoints, environments and limitations.

Why this matters
APIs reduce manual work and improve tracking, reporting and order visibility.

Example / expected format
Order API, product API, tracking API, authentication, rate limits, sample request/response, error codes.$txt$,
    example_response = $txt$Order API, product API, tracking API, authentication, rate limits, sample request/response, error codes.$txt$
where title = $txt$API documentation$txt$;

update public.requirements
set our_need = $txt$What we need
Please explain access controls, user permissions and how access is granted, reviewed and revoked.

Why this matters
We need assurance that customer and order data is only accessible to authorized users.

Example / expected format
Role-based access, quarterly access review, immediate revocation after employee departure.$txt$,
    example_response = $txt$Role-based access, quarterly access review, immediate revocation after employee departure.$txt$
where title = $txt$Access control policy$txt$;

update public.requirements
set our_need = $txt$What we need
Please confirm the address change window and the process to submit an address change.

Why this matters
Address errors create failed deliveries, returns and customer dissatisfaction.

Example / expected format
Address change allowed within 12 hours. Required fields: street, apartment, city, country, postcode. Submit via email/API.$txt$,
    example_response = $txt$Address change allowed within 12 hours. Required fields: street, apartment, city, country, postcode. Submit via email/API.$txt$
where title = $txt$Address change window$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide authentication method, sandbox access and technical requirements.

Why this matters
We need a secure testing environment before launch.

Example / expected format
OAuth/API key, sandbox URL, test credentials, IP restrictions, rate limits and support contact.$txt$,
    example_response = $txt$OAuth/API key, sandbox URL, test credentials, IP restrictions, rate limits and support contact.$txt$
where title = $txt$Authentication and sandbox access$txt$;

update public.requirements
set our_need = $txt$What we need
Please list available reports for production, late orders, shipped orders, tracking, delivery performance, returns, defects, compensation and finance.

Why this matters
Reporting is required to monitor daily operations and supplier performance.

Example / expected format
Reports available: daily late order report, shipped order report, tracking exceptions, defects, compensation, invoice reconciliation.$txt$,
    example_response = $txt$Reports available: daily late order report, shipped order report, tracking exceptions, defects, compensation, invoice reconciliation.$txt$
where title = $txt$Available operational reports$txt$;

update public.requirements
set our_need = $txt$What we need
Please explain brand approval workflow for assets, packaging, content and campaigns.

Why this matters
Approvals prevent incorrect or non-compliant customer-facing content.

Example / expected format
Submit asset → supplier/brand review within X days → approval/rejection comments → final approved version stored.$txt$,
    example_response = $txt$Submit asset → supplier/brand review within X days → approval/rejection comments → final approved version stored.$txt$
where title = $txt$Brand approval workflow$txt$;

update public.requirements
set our_need = $txt$What we need
Please confirm available gift box, gift card, branded insert and company-branded packaging options. Include price, process, MOQ, lead time and required assets.

Why this matters
Packaging and gifting options are important for customer experience and brand consistency.

Example / expected format
Gift box: $X per unit, MOQ 500, 15-day setup. Gift card: PDF template required, printed in black/white or color.$txt$,
    example_response = $txt$Gift box: $X per unit, MOQ 500, 15-day setup. Gift card: PDF template required, printed in black/white or color.$txt$
where title = $txt$Branded gift box, gift card and insert options$txt$;

update public.requirements
set our_need = $txt$What we need
Please list any branding restrictions, required supplier branding, marketplace limitations, legal restrictions or claims that cannot be used.

Why this matters
We need to avoid brand, legal or compliance issues before launch.

Example / expected format
Supplier logo appears: yes/no. Restricted words: warranty, hypoallergenic, handmade. Country restrictions: X/Y/Z.$txt$,
    example_response = $txt$Supplier logo appears: yes/no. Restricted words: warranty, hypoallergenic, handmade. Country restrictions: X/Y/Z.$txt$
where title = $txt$Branding restrictions$txt$;

update public.requirements
set our_need = $txt$What we need
Please confirm your business hours, time zone, weekend coverage, holiday coverage and any days where production, shipping or support is closed.

Why this matters
Customer communication and delivery promises depend on knowing when your teams can act on production, shipping and urgent requests.

Example / expected format
Time zone: EST
Monday-Friday: 09:00-18:00
Saturday coverage: yes/no
Emergency weekend coverage: yes/no
Holiday calendar attached$txt$,
    example_response = $txt$Time zone: EST
Monday-Friday: 09:00-18:00
Saturday coverage: yes/no
Emergency weekend coverage: yes/no
Holiday calendar attached$txt$
where title = $txt$Business hours, weekends and holidays$txt$;

update public.requirements
set our_need = $txt$What we need
Please propose business review cadence and topics: SLA, quality, compensation, finance, incidents and improvement plan.

Why this matters
Regular reviews keep the partnership controlled after launch.

Example / expected format
Monthly business review: SLA, late orders, defects, returns, compensation, finance disputes, improvement actions.$txt$,
    example_response = $txt$Monthly business review: SLA, late orders, defects, returns, compensation, finance disputes, improvement actions.$txt$
where title = $txt$Business review cadence$txt$;

update public.requirements
set our_need = $txt$What we need
Please confirm the cancellation window after order placement and the exact cutoff after which cancellation is no longer possible.

Why this matters
Customer service needs a clear answer when customers request cancellation.

Example / expected format
Cancellation allowed within 2 hours after order placement and only before shipment/production lock.$txt$,
    example_response = $txt$Cancellation allowed within 2 hours after order placement and only before shipment/production lock.$txt$
where title = $txt$Cancellation window$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide all carriers used, supported countries, factory availability and known restrictions.

Why this matters
Carrier restrictions affect ETA, delivery exceptions and customer communication.

Example / expected format
DHL: US/EU, no PO boxes. UPS: US only. Local carrier: Canada, no weekend delivery.$txt$,
    example_response = $txt$DHL: US/EU, no PO boxes. UPS: US only. Local carrier: Canada, no weekend delivery.$txt$
where title = $txt$Carrier list and restrictions$txt$;

update public.requirements
set our_need = $txt$What we need
Please explain how compensation and credit notes are created, approved and reconciled with invoices.

Why this matters
Compensation must be traceable and not managed manually outside finance records.

Example / expected format
SLA breach approved → credit note created monthly → credit note linked to order IDs → deducted from next invoice.$txt$,
    example_response = $txt$SLA breach approved → credit note created monthly → credit note linked to order IDs → deducted from next invoice.$txt$
where title = $txt$Compensation and credit note process$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide compliance requirements, certifications or restrictions that apply to products and countries served.

Why this matters
Compliance issues can block sales, shipping or marketing claims.

Example / expected format
Product safety certification, material compliance, country restrictions, labeling requirements.$txt$,
    example_response = $txt$Product safety certification, material compliance, country restrictions, labeling requirements.$txt$
where title = $txt$Compliance requirements$txt$;

update public.requirements
set our_need = $txt$What we need
Please list content usage restrictions, brand restrictions and forbidden claims.

Why this matters
We must avoid using claims or assets that are not allowed.

Example / expected format
Forbidden claims: waterproof, lifetime guarantee, medical/health claims. Approved claims listed in guideline.$txt$,
    example_response = $txt$Forbidden claims: waterproof, lifetime guarantee, medical/health claims. Approved claims listed in guideline.$txt$
where title = $txt$Content usage restrictions$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide contract, terms and commercial conditions applicable to the partnership.

Why this matters
Legal and commercial terms must be validated before launch.

Example / expected format
Master agreement, commercial terms, product terms, shipping terms, compensation terms.$txt$,
    example_response = $txt$Master agreement, commercial terms, product terms, shipping terms, compensation terms.$txt$
where title = $txt$Contract and terms$txt$;

update public.requirements
set our_need = $txt$What we need
Please confirm how you will provide a daily report covering 100% of orders late against production SLA. The report must include order ID, delay reason, new deadline, shipping method and upgrade status.

Why this matters
A partial report is not useful. We need full visibility to manage customers and compensation.

Example / expected format
Order #12345 | SLA ship date: May 10 | New ship date: May 11 | Reason: material delay | Upgrade: Express$txt$,
    example_response = $txt$Order #12345 | SLA ship date: May 10 | New ship date: May 11 | Reason: material delay | Upgrade: Express$txt$
where title = $txt$Daily late order report covering 100% of late orders$txt$;

update public.requirements
set our_need = $txt$What we need
Please confirm daily morning reporting of orders at risk before event delivery deadlines, based on current tracking and production status.

Why this matters
We need to know which orders may miss event delivery before customers complain.

Example / expected format
Daily report: order ID, customer country, tracking status, ETA, risk reason, recovery action, compensation status.$txt$,
    example_response = $txt$Daily report: order ID, customer country, tracking status, ETA, risk reason, recovery action, compensation status.$txt$
where title = $txt$Daily orders-at-risk reporting$txt$;

update public.requirements
set our_need = $txt$What we need
Please confirm which reports can be automated daily and how they will be delivered. Late orders and orders at risk are priority.

Why this matters
Manual reporting creates gaps. Daily automation is required for operational control.

Example / expected format
Daily email at 09:00 with CSV attachment, or dashboard access with export option.$txt$,
    example_response = $txt$Daily email at 09:00 with CSV attachment, or dashboard access with export option.$txt$
where title = $txt$Daily reporting automation$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide the damaged/defective item claim process: required evidence, timeframe, approval flow, reorder/refund eligibility and supplier responsibility.

Why this matters
Damaged claims must be handled quickly and consistently.

Example / expected format
Required: order ID, photos of item on all sides, photos of outer packaging and shipping label. Review within 48 hours.$txt$,
    example_response = $txt$Required: order ID, photos of item on all sides, photos of outer packaging and shipping label. Review within 48 hours.$txt$
where title = $txt$Damaged item claim process$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide the damaged/defect rate KPI you track, how it is calculated, reporting frequency and the threshold that triggers review and corrective action.

Why this matters
If defect or damage rates exceed the agreed threshold, we need root cause analysis, corrective action and compensation discussion.

Example / expected format
Monthly defect rate = defective units / shipped units. Threshold: 2%. If above threshold: RCA within 5 business days + corrective action plan.$txt$,
    example_response = $txt$Monthly defect rate = defective units / shipped units. Threshold: 2%. If above threshold: RCA within 5 business days + corrective action plan.$txt$
where title = $txt$Damaged/defect rate KPI and review threshold$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide DPA or privacy documentation if customer personal data is processed.

Why this matters
Customer data must be handled according to privacy and compliance requirements.

Example / expected format
DPA attached. Data processed: name, address, email, order details, personalization data. Sub-processors listed.$txt$,
    example_response = $txt$DPA attached. Data processed: name, address, email, order details, personalization data. Sub-processors listed.$txt$
where title = $txt$Data processing agreement$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide data retention, deletion and backup rules.

Why this matters
Customer data should not be stored longer than necessary and must be recoverable when needed.

Example / expected format
Order data retained X months/years. Personalization files deleted after X days. Backups retained X days.$txt$,
    example_response = $txt$Order data retained X months/years. Personalization files deleted after X days. Backups retained X days.$txt$
where title = $txt$Data retention policy$txt$;

update public.requirements
set our_need = $txt$What we need
Please confirm the process when an order is 1 day late: flagging, reason, owner and plan to ship the next day.

Why this matters
Day 1 late orders must be identified immediately so we can manage customer communication.

Example / expected format
Tag: Late Supplier. Reason: QC issue. New ship date: D+1. Owner: Production manager.$txt$,
    example_response = $txt$Tag: Late Supplier. Reason: QC issue. New ship date: D+1. Owner: Production manager.$txt$
where title = $txt$Day 1 late supplier process$txt$;

update public.requirements
set our_need = $txt$What we need
Please confirm the process when an order is 2+ days late. We expect a detailed reason, new confirmed deadline and automatic shipping upgrade at supplier expense. If the order already uses the most expensive method, shipping fees should be refunded.

Why this matters
Longer production delays require immediate recovery action and compensation.

Example / expected format
Order late 2 days → root cause shared → new ship date confirmed → shipping upgraded to Express at supplier cost.$txt$,
    example_response = $txt$Order late 2 days → root cause shared → new ship date confirmed → shipping upgraded to Express at supplier cost.$txt$
where title = $txt$Day 2+ late process with automatic shipping upgrade$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide the process for impossible delivery, wrong address, return to sender, lost package, business closed, customer unavailable and other exceptions.

Why this matters
Delivery exceptions need clear ownership and action to avoid unresolved customer cases.

Example / expected format
Exception detected → affected order list sent → action required from customer/Tenengroup → supplier/carrier next action confirmed.$txt$,
    example_response = $txt$Exception detected → affected order list sent → action required from customer/Tenengroup → supplier/carrier next action confirmed.$txt$
where title = $txt$Delivery exceptions process$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide volume discount tiers, discount rules and any specific commercial agreement that may apply.

Why this matters
We need to understand how pricing evolves with volume and how discounts are applied in invoices.

Example / expected format
0-500 orders: $X
501-1000 orders: $Y
1000+ orders: $Z
Discount reviewed monthly/quarterly$txt$,
    example_response = $txt$0-500 orders: $X
501-1000 orders: $Y
1000+ orders: $Z
Discount reviewed monthly/quarterly$txt$
where title = $txt$Discount and volume structure$txt$;

update public.requirements
set our_need = $txt$What we need
Please define the compensation process when an order is not delivered within ETA and the delay is not caused by the customer.

Why this matters
When delivery promises are missed, we need clear compensation rules and invoice handling.

Example / expected format
Delivered after ETA due to carrier issue → shipping fee credited/refunded → carrier claim opened where applicable.$txt$,
    example_response = $txt$Delivered after ETA due to carrier issue → shipping fee credited/refunded → carrier claim opened where applicable.$txt$
where title = $txt$ETA miss and shipping compensation process$txt$;

update public.requirements
set our_need = $txt$What we need
Please explain the process for urgent production, shipping, tracking or technical incidents: channel, owner, backup contact, response time and escalation steps.

Why this matters
Urgent issues must be handled quickly to avoid missed delivery promises and customer dissatisfaction.

Example / expected format
Urgent issue reported by email/Slack → Level 1 responds within 1 hour → Level 2 escalation after 2 hours → daily follow-up until solved$txt$,
    example_response = $txt$Urgent issue reported by email/Slack → Level 1 responds within 1 hour → Level 2 escalation after 2 hours → daily follow-up until solved$txt$
where title = $txt$Emergency communication process$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide escalation levels, contacts, timing and what qualifies as urgent.

Why this matters
Clear escalation prevents unresolved operational issues.

Example / expected format
Level 1 after SLA breach. Level 2 after 4 hours unresolved. Level 3 executive escalation after 24 hours or critical event risk.$txt$,
    example_response = $txt$Level 1 after SLA breach. Level 2 after 4 hours unresolved. Level 3 executive escalation after 24 hours or critical event risk.$txt$
where title = $txt$Escalation process$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide event capacity plan for Valentine’s Day, Mother’s Day, Father’s Day, Christmas, Black Friday and Cyber Monday, including staffing, monitoring and escalation.

Why this matters
During peak events, any production or shipping issue has a major customer impact.

Example / expected format
Peak plan: forecast volume, daily capacity, extra staff, extended hours, escalation owner, daily monitoring report.$txt$,
    example_response = $txt$Peak plan: forecast volume, daily capacity, extra staff, extended hours, escalation owner, daily monitoring report.$txt$
where title = $txt$Event capacity plan$txt$;

update public.requirements
set our_need = $txt$What we need
Please define compensation rules for event orders delivered late or at risk, including shipping reimbursement, free order, credit note and carrier claim process.

Why this matters
Event misses are highly sensitive and compensation must be clear before peak season.

Example / expected format
If event delivery is missed due to supplier/carrier issue: shipping credited, carrier claim opened, free replacement considered depending on case.$txt$,
    example_response = $txt$If event delivery is missed due to supplier/carrier issue: shipping credited, carrier claim opened, free replacement considered depending on case.$txt$
where title = $txt$Event delivery compensation process$txt$;

update public.requirements
set our_need = $txt$What we need
Please confirm final go-live approval criteria for operations, tech, finance, customer service and reporting.

Why this matters
Both teams need the same definition of readiness.

Example / expected format
Go-live approved only when catalog, pricing, test orders, tracking, SLA, support and finance are validated.$txt$,
    example_response = $txt$Go-live approved only when catalog, pricing, test orders, tracking, SLA, support and finance are validated.$txt$
where title = $txt$Final approval criteria$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide launch checklist with owner and status for each item.

Why this matters
A shared checklist ensures nothing is missed before launch.

Example / expected format
Catalog approved, pricing approved, API tested, test orders passed, SLA approved, support contacts confirmed, finance process validated.$txt$,
    example_response = $txt$Catalog approved, pricing approved, API tested, test orders passed, SLA approved, support contacts confirmed, finance process validated.$txt$
where title = $txt$Go-live checklist$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide hypercare plan after launch: duration, support coverage, escalation and daily monitoring.

Why this matters
The first days after launch require closer monitoring and faster issue resolution.

Example / expected format
Hypercare duration: 2 weeks. Daily standup: yes. Dedicated escalation contact. Daily report sent at 09:00.$txt$,
    example_response = $txt$Hypercare duration: 2 weeks. Daily standup: yes. Dedicated escalation contact. Daily report sent at 09:00.$txt$
where title = $txt$Hypercare plan$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide image and media specifications: format, size, naming convention, lifestyle images, mockups, thumbnails and restrictions by product type.

Why this matters
Consistent media rules are required for product pages, catalog integration and customer experience.

Example / expected format
Main image: JPG/PNG, 2000x2000, white background. Lifestyle images: optional. File naming: SKU_variant_angle.jpg.$txt$,
    example_response = $txt$Main image: JPG/PNG, 2000x2000, white background. Lifestyle images: optional. File naming: SKU_variant_angle.jpg.$txt$
where title = $txt$Image and media specifications$txt$;

update public.requirements
set our_need = $txt$What we need
Please explain how inventory is synchronized, update frequency, data format, ownership and what happens if the sync fails.

Why this matters
Inventory visibility prevents overselling, cancellations and customer disappointment.

Example / expected format
Inventory feed updates every 2 hours. If feed fails, supplier notifies Tenengroup within 1 hour and blocks affected SKUs.$txt$,
    example_response = $txt$Inventory feed updates every 2 hours. If feed fails, supplier notifies Tenengroup within 1 hour and blocks affected SKUs.$txt$
where title = $txt$Inventory sync process$txt$;

update public.requirements
set our_need = $txt$What we need
Please explain how invoices are consolidated and linked to orders, including product cost, shipping, credits, compensation and specific agreements.

Why this matters
Finance needs order-level reconciliation and visibility on compensation.

Example / expected format
Invoice line includes order ID, SKU, product cost, shipping cost, discount, credit note reference and compensation reason.$txt$,
    example_response = $txt$Invoice line includes order ID, SKU, product cost, shipping cost, discount, credit note reference and compensation reason.$txt$
where title = $txt$Invoice consolidation process$txt$;

update public.requirements
set our_need = $txt$What we need
Please explain issue management process: ticketing, owner, severity, SLA, follow-up and resolution confirmation.

Why this matters
Issues need consistent tracking until closure.

Example / expected format
Issue logged → severity assigned → owner assigned → SLA timer starts → updates every X hours → closure confirmed by Tenengroup.$txt$,
    example_response = $txt$Issue logged → severity assigned → owner assigned → SLA timer starts → updates every X hours → closure confirmed by Tenengroup.$txt$
where title = $txt$Issue management process$txt$;

update public.requirements
set our_need = $txt$What we need
Please define KPI calculations and export format for production SLA, late supplier, tracking, delivery ETA, returns, defects and compensation.

Why this matters
Both teams must use the same KPI definitions to avoid disputes.

Example / expected format
Late supplier % = orders shipped after SLA / total shipped orders. Export: CSV with order-level detail.$txt$,
    example_response = $txt$Late supplier % = orders shipped after SLA / total shipped orders. Export: CSV with order-level detail.$txt$
where title = $txt$KPI definitions and export format$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide the full contact list and escalation matrix for daily operations and emergencies, including names, roles, email, phone/WhatsApp if available, working hours, backup contacts and escalation level.

Why this matters
We support customers 24/7 and need to know exactly who to contact depending on the topic, urgency, time of day, weekend or holiday.

Example / expected format
Operations: Name / email / hours
Logistics: Name / email / hours
Emergency escalation: Level 1 contact, Level 2 contact, expected response time$txt$,
    example_response = $txt$Operations: Name / email / hours
Logistics: Name / email / hours
Emergency escalation: Level 1 contact, Level 2 contact, expected response time$txt$
where title = $txt$Key contacts and escalation matrix$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide last safe order date, production date and shipping date by country and shipping method for each event.

Why this matters
We need to know the last possible date to promise delivery on time.

Example / expected format
Country | Method | Last order date | Last production completion date | Last ship date | Expected delivery date$txt$,
    example_response = $txt$Country | Method | Last order date | Last production completion date | Last ship date | Expected delivery date$txt$
where title = $txt$Last safe shipping date matrix$txt$;

update public.requirements
set our_need = $txt$What we need
Please list blockers, dependencies and risks that can delay launch.

Why this matters
Blockers need visibility and ownership before we commit to a launch date.

Example / expected format
Blocker: API credentials not ready. Owner: supplier tech. Due date: June 10. Impact: launch cannot proceed.$txt$,
    example_response = $txt$Blocker: API credentials not ready. Owner: supplier tech. Due date: June 10. Impact: launch cannot proceed.$txt$
where title = $txt$Launch blockers and dependencies$txt$;

update public.requirements
set our_need = $txt$What we need
Please explain how we can access live shipment tracking data for every shipment: tracking number, carrier, method, status and ETA. API, feed or dashboard is preferred.

Why this matters
Tracking visibility is critical for proactive customer service and delivery-risk management.

Example / expected format
API endpoint or daily feed with order ID, tracking number, carrier, status, last scan, ETA and delivery exception.$txt$,
    example_response = $txt$API endpoint or daily feed with order ID, tracking number, carrier, status, last scan, ETA and delivery exception.$txt$
where title = $txt$Live tracking data access$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide the full list of mandatory product attributes required for each SKU and variant.

Why this matters
Missing attributes create integration issues, incorrect product pages and operational errors.

Example / expected format
Required fields: SKU, product title, variant title, dimensions, weight, materials, personalization fields, production time, images, shipping restrictions.$txt$,
    example_response = $txt$Required fields: SKU, product title, variant title, dimensions, weight, materials, personalization fields, production time, images, shipping restrictions.$txt$
where title = $txt$Mandatory product attributes$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide available marketing assets, product images, videos, copy, mockups and usage rights.

Why this matters
Assets help launch products faster and maintain brand/product accuracy.

Example / expected format
Asset library link with product images, lifestyle images, videos, copy, usage rights and expiration date if applicable.$txt$,
    example_response = $txt$Asset library link with product images, lifestyle images, videos, copy, usage rights and expiration date if applicable.$txt$
where title = $txt$Marketing assets availability$txt$;

update public.requirements
set our_need = $txt$What we need
Please confirm the process when a supplier cutoff is missed. We expect automatic shipping upgrade until the last express cutoff. If the last express cutoff is missed, provide the affected order list immediately and propose free order + urgent method where applicable.

Why this matters
Missed event cutoffs require immediate recovery and compensation.

Example / expected format
Order misses standard cutoff → upgrade to express. Order misses express cutoff → same-day affected list + compensation proposal.$txt$,
    example_response = $txt$Order misses standard cutoff → upgrade to express. Order misses express cutoff → same-day affected list + compensation proposal.$txt$
where title = $txt$Missed cutoff process$txt$;

update public.requirements
set our_need = $txt$What we need
Please describe all neutral, branded and white-label packaging options and any limitation.

Why this matters
The customer should experience our brand, not the supplier brand, unless explicitly approved.

Example / expected format
Neutral mailer with no supplier logo. Optional branded box available with MOQ and setup cost.$txt$,
    example_response = $txt$Neutral mailer with no supplier logo. Optional branded box available with MOQ and setup cost.$txt$
where title = $txt$Neutral and branded packaging options$txt$;

update public.requirements
set our_need = $txt$What we need
Please explain the out-of-stock process: notification timing, order blocking, alternatives, substitution rules and customer protection.

Why this matters
We must avoid selling products that cannot be fulfilled.

Example / expected format
SKU out of stock → notify within 2 hours → product paused → affected orders listed → alternative SKU proposed if available.$txt$,
    example_response = $txt$SKU out of stock → notify within 2 hours → product paused → affected orders listed → alternative SKU proposed if available.$txt$
where title = $txt$Out-of-stock handling$txt$;

update public.requirements
set our_need = $txt$What we need
Please explain packing slip, gift card, marketing insert and package insert rules. Confirm what can be customized and what must be supplied by us.

Why this matters
Incorrect inserts or supplier branding can damage customer experience and brand consistency.

Example / expected format
Packing slip: no price, no supplier logo. Insert: Tenengroup provides artwork PDF, supplier prints and inserts.$txt$,
    example_response = $txt$Packing slip: no price, no supplier logo. Insert: Tenengroup provides artwork PDF, supplier prints and inserts.$txt$
where title = $txt$Packing slip and insert rules$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide payment terms, finance contacts and billing calendar.

Why this matters
Clear finance ownership avoids payment and reconciliation delays.

Example / expected format
Payment terms: Net 30. Invoice sent weekly/monthly. Finance contact: name/email. Dispute window: X days.$txt$,
    example_response = $txt$Payment terms: Net 30. Invoice sent weekly/monthly. Finance contact: name/email. Dispute window: X days.$txt$
where title = $txt$Payment terms and finance contacts$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide your production capacity plan for peak periods: Valentine’s Day, Mother’s Day, Father’s Day, Christmas, Black Friday and Cyber Monday.

Why this matters
Peak periods create high volume and delivery-risk exposure. We need proof that capacity and escalation are ready.

Example / expected format
Normal capacity: 1,000/day. Peak capacity: 2,500/day. Extra shifts: yes. Temporary staff: yes. Peak command center: yes.$txt$,
    example_response = $txt$Normal capacity: 1,000/day. Peak capacity: 2,500/day. Extra shifts: yes. Temporary staff: yes. Peak command center: yes.$txt$
where title = $txt$Peak season production capacity$txt$;

update public.requirements
set our_need = $txt$What we need
Please list every personalization option available and the related limitations: text, name, photo, engraving, artwork, language, character limits, preview validation and error prevention.

Why this matters
Personalized orders are high-risk because mistakes cannot always be corrected after production starts.

Example / expected format
Product A: engraving, 20 characters max, English only. Product B: photo upload, JPG/PNG, minimum resolution 1000x1000.$txt$,
    example_response = $txt$Product A: engraving, 20 characters max, English only. Product B: photo upload, JPG/PNG, minimum resolution 1000x1000.$txt$
where title = $txt$Personalization options$txt$;

update public.requirements
set our_need = $txt$What we need
Please explain your price change process: notice period, approval flow, effective date and how existing orders are handled.

Why this matters
Uncontrolled price changes create margin and invoice issues.

Example / expected format
Supplier sends notice 30 days before change → Tenengroup approval → effective date confirmed → existing orders keep previous price.$txt$,
    example_response = $txt$Supplier sends notice 30 days before change → Tenengroup approval → effective date confirmed → existing orders keep previous price.$txt$
where title = $txt$Price change notification process$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide the product feed format, a sample file, update frequency, owner and process for correcting feed errors.

Why this matters
Accurate product data is required for integration, product launch and ongoing maintenance.

Example / expected format
CSV or XML feed sent daily at 06:00 UTC. Sample includes SKU, title, variants, images, price, production time and availability.$txt$,
    example_response = $txt$CSV or XML feed sent daily at 06:00 UTC. Sample includes SKU, title, variants, images, price, production time and availability.$txt$
where title = $txt$Product feed format and sample file$txt$;

update public.requirements
set our_need = $txt$What we need
Please confirm production SLA and how breaches are tracked, reported and compensated.

Why this matters
Production SLA is the baseline for late supplier monitoring.

Example / expected format
Production SLA: 2 business days. Breach report sent daily. Breach recovery: upgraded shipping at supplier cost.$txt$,
    example_response = $txt$Production SLA: 2 business days. Breach report sent daily. Breach recovery: upgraded shipping at supplier cost.$txt$
where title = $txt$Production SLA$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide production SLA by order type: standard, personalized, peak season, reorders and urgent cases.

Why this matters
We need clear production commitments for customer communication and SLA monitoring.

Example / expected format
Standard: 2 business days. Personalized: 3 business days. Peak season: 4 business days. Reorder: 1-2 business days.$txt$,
    example_response = $txt$Standard: 2 business days. Personalized: 3 business days. Peak season: 4 business days. Reorder: 1-2 business days.$txt$
where title = $txt$Production SLA by order type$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide production cutoff rules for cancellation, address change, shipping upgrade and product modification.

Why this matters
We need to know exactly when an order becomes locked and cannot be changed.

Example / expected format
Order placed 10:00 → cancellation cutoff 12:00 → address cutoff 22:00 → production locked after artwork validation.$txt$,
    example_response = $txt$Order placed 10:00 → cancellation cutoff 12:00 → address cutoff 22:00 → production locked after artwork validation.$txt$
where title = $txt$Production cutoff rules$txt$;

update public.requirements
set our_need = $txt$What we need
Please describe the full production workflow from order reception to shipment, including steps, checkpoints, responsibilities, cutoffs and exception handling.

Why this matters
This is critical to understand where delays may occur and how they are managed before they impact customers.

Example / expected format
Order received → personalization validation → production → quality control → packaging → shipping label → carrier handoff.$txt$,
    example_response = $txt$Order received → personalization validation → production → quality control → packaging → shipping label → carrier handoff.$txt$
where title = $txt$Production workflow$txt$;

update public.requirements
set our_need = $txt$What we need
Please describe your quality control process before shipment and confirm your commitment to quality standards for all products proposed to us. Include checkpoints, sampling rules, rejection process and corrective actions.

Why this matters
Product quality impacts customer satisfaction, refunds, reorders, compensation and brand reputation.

Example / expected format
Artwork validation → production check → final QC → packaging check → shipment release. Failed items are blocked and remade before shipping.$txt$,
    example_response = $txt$Artwork validation → production check → final QC → packaging check → shipment release. Failed items are blocked and remade before shipping.$txt$
where title = $txt$Quality control process and quality commitment$txt$;

update public.requirements
set our_need = $txt$What we need
Please define refund, reorder, exchange and store credit process, including timelines and who pays in each scenario.

Why this matters
Finance and customer service need clear rules to avoid inconsistent decisions.

Example / expected format
Defective item: free reorder or full refund. Customer preference issue on personalized item: store credit only. Processing time: X days.$txt$,
    example_response = $txt$Defective item: free reorder or full refund. Customer preference issue on personalized item: store credit only. Processing time: X days.$txt$
where title = $txt$Refund, reorder and store credit process$txt$;

update public.requirements
set our_need = $txt$What we need
Please confirm return eligibility rules for personalized and non-personalized products, aligned with the relevant brand policy.

Why this matters
Supplier rules must match the customer-facing policy to avoid disputes.

Example / expected format
Personalized: exchange/store credit only unless defective. Non-personalized: return accepted within agreed timeframe if unworn/unused.$txt$,
    example_response = $txt$Personalized: exchange/store credit only unless defective. Non-personalized: return accepted within agreed timeframe if unworn/unused.$txt$
where title = $txt$Return eligibility rules$txt$;

update public.requirements
set our_need = $txt$What we need
Please define compensation rules when SLA is breached: shipping upgrade, shipping refund, free order, credit note or other agreed compensation.

Why this matters
When commitments are missed, compensation must be automatic and invoice-ready.

Example / expected format
Production late 2+ days: express upgrade. Missed final event cutoff: free order + urgent method. ETA miss: shipping credit.$txt$,
    example_response = $txt$Production late 2+ days: express upgrade. Missed final event cutoff: free order + urgent method. ETA miss: shipping credit.$txt$
where title = $txt$SLA breach compensation$txt$;

update public.requirements
set our_need = $txt$What we need
Please explain safety stock rules and how stock is protected during peak periods.

Why this matters
Peak periods require additional protection to avoid overselling and late orders.

Example / expected format
Minimum safety stock: 10% of forecast. Peak safety stock: 20%. Replenishment trigger: 7 days before stockout.$txt$,
    example_response = $txt$Minimum safety stock: 10% of forecast. Peak safety stock: 20%. Replenishment trigger: 7 days before stockout.$txt$
where title = $txt$Safety stock rules$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide security certifications or security documentation relevant to systems, data and integrations.

Why this matters
Security documentation is required for data and system trust.

Example / expected format
SOC 2/ISO certification if available, security policy, incident response process, penetration test summary.$txt$,
    example_response = $txt$SOC 2/ISO certification if available, security policy, incident response process, penetration test summary.$txt$
where title = $txt$Security certifications$txt$;

update public.requirements
set our_need = $txt$What we need
Please confirm shipping SLA by method and country, including ETA calculation and carrier responsibility.

Why this matters
Shipping SLA determines customer promise and compensation rules.

Example / expected format
Standard US: 5-7 business days from ship date. Express US: 1-3 business days. ETA excludes customer address issues.$txt$,
    example_response = $txt$Standard US: 5-7 business days from ship date. Express US: 1-3 business days. ETA excludes customer address issues.$txt$
where title = $txt$Shipping SLA$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide shipping costs by method, country, factory and surcharge rules.

Why this matters
Shipping cost must be transparent for pricing, upgrades and compensation.

Example / expected format
US Standard: $X, 5-7 days. US Express: $Y, 1-3 days. Remote area surcharge: $Z.$txt$,
    example_response = $txt$US Standard: $X, 5-7 days. US Express: $Y, 1-3 days. Remote area surcharge: $Z.$txt$
where title = $txt$Shipping cost matrix$txt$;

update public.requirements
set our_need = $txt$What we need
Please confirm how you will proactively alert us of shipping incidents that may put ETA at risk: weather, carrier delay, strike, hub backlog, customs issue or depot delay.

Why this matters
We need early warnings before customers contact us.

Example / expected format
Incident alert sent by email within 2 hours: affected orders, carrier, reason, expected impact, recovery plan.$txt$,
    example_response = $txt$Incident alert sent by email within 2 hours: affected orders, carrier, reason, expected impact, recovery plan.$txt$
where title = $txt$Shipping incident alerts$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide a shipping method matrix by country, factory and speed, ordered from fastest to slowest with availability limits.

Why this matters
We need to choose the correct shipping promise and identify upgrade options.

Example / expected format
Country | Factory | Method | Carrier | Transit time | Available yes/no | Restrictions$txt$,
    example_response = $txt$Country | Factory | Method | Carrier | Transit time | Available yes/no | Restrictions$txt$
where title = $txt$Shipping method matrix by country and factory$txt$;

update public.requirements
set our_need = $txt$What we need
Please confirm when and how shipping method upgrades can be requested, including cutoff time, cost and operational limitations.

Why this matters
Shipping upgrades are an important recovery tool for late orders and event deadlines.

Example / expected format
Upgrade request before shipping label creation. Cost difference charged unless upgrade is due to supplier delay.$txt$,
    example_response = $txt$Upgrade request before shipping label creation. Cost difference charged unless upgrade is due to supplier delay.$txt$
where title = $txt$Shipping method upgrade process$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide response SLA for standard requests, urgent production issues, shipping incidents, technical issues and peak season.

Why this matters
Response time must match customer-impact severity.

Example / expected format
Standard: 24h. Urgent production/shipping: 2h. Peak season critical incident: 1h. Technical outage: 1h.$txt$,
    example_response = $txt$Standard: 24h. Urgent production/shipping: 2h. Peak season critical incident: 1h. Technical outage: 1h.$txt$
where title = $txt$Supplier support SLA$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide the official support channels for daily supplier communication and operational issues.

Why this matters
We are your customer and need a clear support process.

Example / expected format
Daily requests: email address. Urgent issues: WhatsApp/Slack. Technical issues: ticket portal. Finance: dedicated email.$txt$,
    example_response = $txt$Daily requests: email address. Urgent issues: WhatsApp/Slack. Technical issues: ticket portal. Finance: dedicated email.$txt$
where title = $txt$Supplier support channels$txt$;

update public.requirements
set our_need = $txt$What we need
Please confirm support and escalation SLA for daily operations and urgent incidents.

Why this matters
Operational support must be measurable and consistent.

Example / expected format
Urgent incident: initial response within 2 hours, update every 4 hours until resolved.$txt$,
    example_response = $txt$Urgent incident: initial response within 2 hours, update every 4 hours until resolved.$txt$
where title = $txt$Support and escalation SLA$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide technical owner, backup contact and escalation path.

Why this matters
Technical issues need a clear owner to avoid launch or integration delays.

Example / expected format
Primary tech contact, backup contact, escalation manager, working hours, emergency contact.$txt$,
    example_response = $txt$Primary tech contact, backup contact, escalation manager, working hours, emergency contact.$txt$
where title = $txt$Technical contacts$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide the test plan before launch covering orders, personalization, cancellation, address change, shipping, tracking, returns and finance.

Why this matters
Testing reduces launch risk and validates the end-to-end workflow.

Example / expected format
Test order 1: standard order. Test order 2: personalized order. Test cancellation. Test address change. Test tracking feed. Test invoice.$txt$,
    example_response = $txt$Test order 1: standard order. Test order 2: personalized order. Test cancellation. Test address change. Test tracking feed. Test invoice.$txt$
where title = $txt$Testing plan$txt$;

update public.requirements
set our_need = $txt$What we need
Please confirm webhook support for order status, production status, tracking, cancellation and exceptions.

Why this matters
Webhooks allow us to react in real time to changes and customer-impacting issues.

Example / expected format
Webhook events: order_received, in_production, shipped, tracking_updated, delivery_exception, cancelled.$txt$,
    example_response = $txt$Webhook events: order_received, in_production, shipped, tracking_updated, delivery_exception, cancelled.$txt$
where title = $txt$Webhook support$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide the complete wholesale price list including product cost, personalization cost, packaging cost, shipping cost and any additional operational fees.

Why this matters
Transparent pricing is required to validate margins, customer pricing and finance reconciliation.

Example / expected format
SKU | Product cost | Personalization cost | Gift box cost | Standard shipping | Express shipping | Currency$txt$,
    example_response = $txt$SKU | Product cost | Personalization cost | Gift box cost | Standard shipping | Express shipping | Currency$txt$
where title = $txt$Wholesale price list$txt$;

update public.requirements
set our_need = $txt$What we need
Please provide the process for wrong item, missing item or production mistake: evidence required, replacement timing, refund/reorder rule and supplier responsibility.

Why this matters
Customers expect fast correction when the wrong or incomplete order is received.

Example / expected format
Customer sends order ID + photo of item received → supplier confirms mistake → replacement shipped with priority method.$txt$,
    example_response = $txt$Customer sends order ID + photo of item received → supplier confirms mistake → replacement shipped with priority method.$txt$
where title = $txt$Wrong item or missing item process$txt$;

