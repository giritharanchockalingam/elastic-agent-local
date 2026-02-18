# Email Template PII Compliance Guide

## ⚠️ CRITICAL SECURITY REQUIREMENT

**PII (Personally Identifiable Information) must NEVER be included in plain text email templates.**

This is a legal and regulatory requirement for GDPR, PCI-DSS, and data protection compliance.

## Restricted Fields (MUST NEVER APPEAR IN EMAILS)

The following fields are **FORBIDDEN** from email templates:

### Identity Documents
- `{{id_number}}` / `{{guest_id_number}}`
- `{{passport_number}}` / `{{guest_passport_number}}`
- `{{aadhar_number}}` / `{{guest_aadhar_number}}`
- `{{pan_number}}` / `{{guest_pan_number}}`
- `{{driving_license_number}}`
- `{{voter_id_number}}`
- `{{national_id_number}}`
- `{{ssn}}` / `{{social_security_number}}`

### Personal Information
- `{{date_of_birth}}` / `{{dob}}` / `{{birth_date}}`
- `{{guest_date_of_birth}}` / `{{guest_dob}}`

### Payment Information
- `{{credit_card_number}}` / `{{card_number}}`
- `{{cvv}}` / `{{cvc}}`
- `{{card_expiry}}` / `{{card_expiry_date}}`
- `{{bank_account_number}}`
- `{{ifsc_code}}` / `{{routing_number}}`

## Allowed Fields (Safe to Use)

The following fields are **safe** to use in email templates:

### Guest Information (Masked/Protected)
- `{{guest_name}}` - Full name (OK)
- `{{guest_first_name}}` - First name (OK)
- `{{guest_last_name}}` - Last name (OK)
- `{{guest_phone}}` - **Automatically masked** (shows only last 4 digits: ***-***-1234)
- `{{guest_email}}` - **Protected** (shows privacy notice, not actual email)

### Booking Information
- `{{booking_number}}` / `{{reservation_number}}`
- `{{check_in_date}}` / `{{check_out_date}}`
- `{{check_in_time}}` / `{{check_out_time}}`
- `{{nights}}`
- `{{room_type}}` / `{{room_number}}`
- `{{guest_count}}` / `{{adults}}` / `{{children}}`
- `{{total_amount}}` - Amount only (NOT payment details)
- `{{payment_status}}` - Status only (NOT card numbers)
- `{{special_requests}}` - Sanitized (no PII included)

### Property Information
- `{{hotel_name}}` / `{{property_name}}`
- `{{hotel_phone}}`
- `{{hotel_email}}`
- `{{hotel_address}}` - City/country only (NOT full street address)
- `{{hotel_website}}`

## Compliance Enforcement

### Automatic Checks

1. **Database Trigger**: Templates are automatically checked on create/update
2. **Runtime Validation**: Templates are validated before sending emails
3. **Compliance Status**: View `email_templates_compliance_status` to check all templates

### Manual Compliance Check

```sql
-- Check a specific template
SELECT * FROM check_email_template_compliance('template-id-here');

-- View all template compliance status
SELECT * FROM email_templates_compliance_status;
```

### Violation Handling

If a template contains restricted fields:
- **The email will NOT be sent**
- An error will be logged with violation details
- Template will be marked as non-compliant
- Compliance team will be notified

## Best Practices

1. **Never include ID numbers** - Even if requested, use masked references
2. **Mask phone numbers** - System automatically masks (shows ***-***-1234)
3. **Don't include email in body** - Email is only used for delivery address
4. **Use city/country only** - Never include full street addresses
5. **Amounts only** - Show payment amounts, never card details
6. **Sanitize special requests** - System automatically removes PII from special requests

## Privacy Policy Requirements

All email templates should include:
- Privacy policy link in footer
- Unsubscribe option (where applicable)
- Data retention information
- Contact information for privacy inquiries

## Legal Requirements

### GDPR (European Union)
- Explicit consent required for email communications
- Right to erasure (delete data on request)
- Data minimization (only include necessary information)
- Privacy by design (built-in protection)

### PCI-DSS (Payment Card Industry)
- Never store or transmit full card numbers
- Mask card numbers in any communications
- No CVV/CVC codes in emails
- Secure transmission required (TLS/SSL)

### Industry Standards
- Hotel data protection best practices
- Guest privacy protection
- Secure communication channels
- Audit trails for compliance

## Reporting Violations

If you find a template with restricted PII:
1. **DO NOT USE IT** - Do not send emails with that template
2. **Report immediately** - Notify compliance team
3. **Fix the template** - Remove restricted fields
4. **Re-validate** - Run compliance check again

## Questions?

Contact the compliance team for questions about:
- What data can be included in emails
- How to mask sensitive information
- Compliance requirements for your region
- Privacy policy requirements

