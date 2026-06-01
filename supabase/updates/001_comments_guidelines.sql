-- Run this after schema.sql and seed.sql if your database already exists.
-- It improves security for comments and replaces generic supplier text with Bruno's supplier-friendly guidelines.

create index if not exists idx_comments_requirement_id on comments(requirement_id);
create index if not exists idx_requirements_workspace_id on requirements(workspace_id);

-- Replace the generic comments insert policy with a stricter workspace-access policy.
drop policy if exists "Comments insert" on comments;
create policy "Comments insert by accessible workspace" on comments
for insert
with check (
  auth.uid() = author_id
  and exists (
    select 1
    from requirements r
    where r.id = requirement_id
      and (
        current_user_role() in ('admin','internal')
        or exists (
          select 1
          from workspace_access wa
          where wa.workspace_id = r.workspace_id
            and wa.user_id = auth.uid()
        )
      )
  )
  and (is_internal = false or current_user_role() in ('admin','internal'))
);

-- Company overview
update requirements set our_need = $$Our customer service operates 24/7 and our delivery operations run from Monday to Saturday.

We need a clear contact and escalation structure so both companies can act quickly during normal business hours, evenings, weekends and urgent situations.

Please provide the operational contacts, escalation contacts, working hours, emergency process and any limitations.$$,
expected_document = 'Contact list, escalation matrix, organization chart if available.'
where title in ('Key contacts and escalation matrix','Business hours, weekends and holidays','Emergency communication process');

-- Products and QA
update requirements set our_need = $$Before products are offered to customers, we need confirmation that they are quality-assured and that the supplier formally commits to product quality.

Please explain your QA process, defect prevention process, damaged/defect monitoring and the threshold from which a product or process must be reviewed.

If damaged/defect rates exceed the agreed threshold, we expect a review, corrective action plan and compensation discussion.$$,
expected_document = 'QA process, quality commitment, defect KPI history, sample quality report.'
where title in ('Quality control process and quality commitment','Damaged/defect rate KPI and review threshold');

update requirements set our_need = $$Please describe all available customization options in detail.

Include product personalization, engraving/text/image options, constraints, preview process, file requirements, production impact, and what can or cannot be changed after order placement.$$,
expected_document = 'Personalization guide, artwork/file requirements, examples.'
where title = 'Personalization options';

update requirements set our_need = $$We need to understand all branded customer-experience options: personalized gift box, gift card, branded inserts and packaging aligned with our company image.

Please provide available options, pricing, MOQ if any, process, lead time, design requirements and operational limitations.$$,
expected_document = 'Packaging options, gift box/gift card price list, design specs, sample photos.'
where title = 'Branded gift box, gift card and insert options';

-- Fulfillment
update requirements set our_need = $$This is a critical section.

We need daily visibility on every order that is late from Day 1, including the reason and the recovery plan.

Day 1 late:
- Order must be tagged as Late Supplier.
- Supplier must provide the delay reason.
- Supplier must provide a new commitment date, normally ship D+1.

Day 2+ late:
- Supplier must provide a detailed reason.
- Supplier must provide a new deadline.
- Supplier must automatically upgrade the shipping method at supplier cost.

If the order already has the most expensive method, shipping fees must be refunded.

This process must cover 100% of orders, not 50% or 70%. Otherwise the dashboard/report has no operational value.$$,
expected_document = 'Production workflow, SLA, daily late-order report sample, upgrade process.'
where title in ('Production workflow and SLA','Daily late order reporting','Late supplier Day 1 process','Late supplier Day 2+ upgrade process','Production capacity and peak season readiness');

-- Shipping
update requirements set our_need = $$Please provide a clear shipping matrix by speed and price.

The matrix must show shipping methods by country/region, factory/location availability, carrier, estimated transit time, cost and restrictions.

We need to understand what method is available for every destination and from every relevant factory.$$,
expected_document = 'Shipping method matrix by country/factory, carrier list, pricing table.'
where title in ('Shipping method matrix by country and factory','Delivery time and cost by method','Shipping restrictions and carrier coverage');

-- Tracking
update requirements set our_need = $$This is a critical section.

We need live visibility on every shipment: tracking number, carrier, method, current status and ETA.

Preferred solution: API, integration, dashboard or tracking feed allowing us to extract all live shipments.

Supplier must proactively notify us of any shipping risk that can impact ETA: weather, depot delay, strike, carrier disruption, customs issue, etc.

For orders not delivered within ETA when the delay is not caused by the customer, we expect compensation and shipping not to be charged.

We also need proactive notification for delivery exceptions: invalid address, return to sender, lost package, business closed, delivery impossible.$$,
expected_document = 'Tracking feed/API documentation, dashboard access, exception report sample.'
where title in ('Live tracking access','Tracking feed/API or dashboard','Shipping disruption communication','Late delivery compensation process','Delivery exception process');

-- Returns
update requirements set our_need = $$We need the supplier to align with our customer policies and operational process for returns, refunds, warranty and damaged items.

Lime&Lou key expectations:
- Defect claims require order ID, issue description, clear product photos and packaging/shipping label photos.
- Lime&Lou items have a 6-month warranty.
- Approved claims may lead to free reorder or full refund.
- Personalized items cannot be exchanged or refunded, except approved defect/wrong item/lost cases.
- Non-personalized items may be returned/exchanged within 60 days and may be subject to a 50% return fee.

TheoGrace / ShineOn key expectations:
- New, unworn items may be returned within 100 days of delivery.
- Non-personalized pieces are eligible for full refund within 30 days of delivery.
- Personalized jewelry may be exchanged or returned for store credit.
- Damaged item claims require photo evidence and clear issue description.

Please confirm your process, evidence requirements, refund/reorder ownership, return address and compensation rules.$$,
expected_document = 'Return policy, damaged item workflow, return address, warranty process, claim evidence requirements.'
where title in ('Return eligibility and address','Refund, exchange and store credit process','Damaged, wrong item and lost order workflow','Warranty and evidence requirements');

-- Order changes
update requirements set our_need = $$We need a clear operational process for customer change requests.

Cancellation:
- For personalized products, production starts quickly.
- Cancellation window is expected up to 2 hours after order placement, only before shipment.

Address change / delivery method change:
- Lime&Lou policy expects changes to be possible up to 12 hours after order placement.
- After the cutoff, changes may no longer be possible.

Please confirm your exact cutoffs, what can be changed, how requests must be submitted, who approves, and how quickly confirmation is returned.$$,
expected_document = 'Cancellation/change policy, cut-off times, operational workflow.'
where title in ('Cancellation window','Address change process','Shipping method upgrade/change process','Product modification cutoff','Refund execution process');

-- Customer service and SLA
update requirements set our_need = $$We are your customer and need a clear customer service process between our teams.

Please define communication channels, contacts, coverage, response SLAs, escalation process and ownership by topic.

We need to know exactly how to contact you for standard requests, urgent production issues, urgent shipping issues and peak season incidents.$$,
expected_document = 'Customer service contact list, SLA matrix, escalation process.'
where title in ('Support channels and contacts','Response SLA by issue type','Escalation process','Ownership split between supplier and Tenengroup');

-- Finance
update requirements set our_need = $$We need clean financial reconciliation between orders, invoices, agreed pricing and compensation.

Please explain how invoices are consolidated, how compensation is identified, how credit notes are issued, and how specific commercial agreements are reflected.$$,
expected_document = 'Billing process, invoice sample, credit note process, compensation tracking sample.'
where title in ('Billing and invoice process','Order-to-invoice reconciliation','Compensation and credit note process','Payment terms and finance contacts');

-- Events
update requirements set our_need = $$During peak events such as Valentine's Day, Mother's Day, Father's Day, Christmas, Black Friday and Cyber Monday, all previously discussed processes become critical.

We cannot accept non-application of communication, late supplier reporting or shipping monitoring during events.

Last safe shipping dates:
- Each shipping method must have a final ship date to deliver on time for the event.
- If an order is late by even one day, supplier must automatically upgrade shipping until the final express cutoff.
- On the final cutoff day, supplier must send the list of orders that missed cutoff immediately after cutoff.
- For missed cutoff orders, expected recovery is free order plus urgent shipping method where applicable.

Last delivery date monitoring:
- On the final delivery day, supplier must send in the morning the list of orders that might be late based on tracking.
- Supplier must provide recovery plan and compensation such as free shipping / shipping refund.
- Supplier is expected to claim compensation from its shipping partner when carrier responsibility applies.$$,
expected_document = 'Event readiness plan, last safe shipping date matrix, at-risk orders report, compensation process.'
where title in ('Event capacity plan','Last safe shipping date matrix','Missed cutoff process','Daily orders-at-risk reporting','Event delivery compensation process');
