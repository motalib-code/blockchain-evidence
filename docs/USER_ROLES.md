# User Roles and Permissions

## Role Hierarchy

```
Administrator (admin)
├── Evidence Manager (evidence_manager)
├── Auditor (auditor)
├── Court Official (court_official)
├── Legal Professional (legal_professional)
├── Forensic Analyst (forensic_analyst)
├── Investigator (investigator)
└── Public Viewer (public_viewer)
```

## Role Definitions

### 1. Public Viewer
**Role Code:** `public_viewer`
**Access Level:** Basic

**Permissions:**
- ✅ View public cases
- ✅ Browse public evidence
- ✅ Access general system information
- ❌ Create or modify content
- ❌ Access sensitive data

**Use Cases:**
- General public access
- Transparency initiatives
- Public information requests

### 2. Investigator
**Role Code:** `investigator`
**Access Level:** Standard

**Permissions:**
- ✅ Create new cases
- ✅ Upload evidence
- ✅ Manage own investigations
- ✅ View assigned cases
- ✅ Generate investigation reports
- ❌ Access other investigators' private cases
- ❌ Modify system settings

**Use Cases:**
- Police officers
- Private investigators
- Detective work
- Case management

### 3. Forensic Analyst
**Role Code:** `forensic_analyst`
**Access Level:** Specialized

**Permissions:**
- ✅ Analyze evidence
- ✅ Generate forensic reports
- ✅ Access technical evidence data
- ✅ Validate evidence integrity
- ✅ Cross-reference evidence
- ❌ Create new cases
- ❌ Delete evidence

**Use Cases:**
- Crime lab technicians
- Digital forensics experts
- Evidence analysis
- Technical validation

### 4. Legal Professional
**Role Code:** `legal_professional`
**Access Level:** Legal

**Permissions:**
- ✅ Review case documentation
- ✅ Access legal evidence
- ✅ Generate legal reports
- ✅ Case status updates
- ✅ Evidence chain of custody review
- ❌ Modify evidence
- ❌ Create investigations

**Use Cases:**
- Lawyers
- Prosecutors
- Defense attorneys
- Legal advisors

### 5. Court Official
**Role Code:** `court_official`
**Access Level:** Judicial

**Permissions:**
- ✅ Access court-related cases
- ✅ Manage court proceedings
- ✅ Evidence presentation
- ✅ Case scheduling
- ✅ Judicial documentation
- ❌ Modify evidence content
- ❌ Create new investigations

**Use Cases:**
- Judges
- Court clerks
- Bailiffs
- Court administrators

### 6. Evidence Manager
**Role Code:** `evidence_manager`
**Access Level:** Administrative

**Permissions:**
- ✅ Manage evidence lifecycle
- ✅ Evidence storage oversight
- ✅ Chain of custody management
- ✅ Evidence disposal
- ✅ Storage compliance
- ✅ Evidence transfers
- ❌ User management
- ❌ System configuration

**Use Cases:**
- Evidence custodians
- Property room managers
- Chain of custody officers
- Storage administrators

### 7. Auditor
**Role Code:** `auditor`
**Access Level:** Oversight

**Permissions:**
- ✅ System audit access
- ✅ Compliance monitoring
- ✅ Activity log review
- ✅ Performance metrics
- ✅ Security assessments
- ✅ Generate audit reports
- ❌ Modify system data
- ❌ User management

**Use Cases:**
- Internal auditors
- Compliance officers
- Security assessors
- Quality assurance

### 8. Administrator
**Role Code:** `admin`
**Access Level:** Full System

**Permissions:**
- ✅ Full system access
- ✅ User management
- ✅ System configuration
- ✅ Create/delete users
- ✅ Manage all roles
- ✅ System monitoring
- ✅ Security settings
- ✅ Backup/restore

**Use Cases:**
- System administrators
- IT managers
- Security officers
- Database administrators

## Permission Matrix

| Feature | Public | Investigator | Forensic | Legal | Court | Evidence Mgr | Auditor | Admin |
|---------|--------|-------------|----------|-------|-------|-------------|---------|-------|
| View Public Cases | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Create Cases | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Upload Evidence | ❌ | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ✅ |
| Analyze Evidence | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Legal Review | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ✅ |
| Manage Users | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| System Audit | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| Evidence Custody | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ |

## Role Assignment

### Self-Registration Roles
Users can self-register for these roles:
- Public Viewer
- Investigator
- Forensic Analyst
- Legal Professional
- Court Official
- Evidence Manager
- Auditor

### Admin-Only Roles
Only administrators can create:
- Administrator accounts (max 10)

### Role Validation
```javascript
const allowedRoles = [
  'public_viewer',
  'investigator', 
  'forensic_analyst',
  'legal_professional',
  'court_official',
  'evidence_manager',
  'auditor'
];

// Admin role cannot be self-registered
if (role === 'admin' && createdBy === 'self') {
  throw new Error('Administrator role cannot be self-registered');
}
```

## Dashboard Access

### Role-Specific Dashboards
- **Public Viewer:** `dashboard-public.html`
- **Investigator:** `dashboard-investigator.html`
- **Forensic Analyst:** `dashboard-analyst.html`
- **Legal Professional:** `dashboard-legal.html`
- **Court Official:** `dashboard-court.html`
- **Evidence Manager:** `dashboard-manager.html`
- **Auditor:** `dashboard-auditor.html`
- **Administrator:** `admin.html`

### Dashboard Features by Role

#### Investigator Dashboard
- Case creation and management
- Evidence upload
- Investigation timeline
- Report generation
- Team collaboration

#### Forensic Analyst Dashboard
- Evidence analysis tools
- Technical reports
- Data validation
- Cross-reference capabilities
- Lab management

#### Legal Professional Dashboard
- Case review interface
- Legal documentation
- Evidence evaluation
- Court preparation
- Legal research tools

#### Admin Dashboard
- User management
- System overview
- Test account creation
- Audit logs
- System configuration

## Security Considerations

### Role-Based Access Control (RBAC)
- Each role has specific permissions
- Access is validated on every request
- Unauthorized actions are logged
- Role escalation is prevented

### Audit Trail
- All role-based actions are logged
- Admin actions are specially tracked
- User role changes are recorded
- Access attempts are monitored

### Best Practices
- Assign minimum required permissions
- Regular role review and updates
- Monitor for privilege escalation
- Implement separation of duties
- Document role assignments