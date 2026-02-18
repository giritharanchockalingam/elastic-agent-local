# Supabase Database Connection Information

## 🔐 How to Find Database Password

Supabase doesn't use a single "database password" in the traditional sense. Instead, you have different credentials depending on how you want to connect:

---

## Method 1: Direct PostgreSQL Connection (psql, pgAdmin, etc.)

For direct database connections, you need the **Database Password** from Supabase Dashboard:

### Steps to Find Database Password:

1. **Go to Supabase Dashboard:**
   - Visit: https://app.supabase.com
   - Select your project: `crumfjyjvofleoqfpwzm`

2. **Navigate to Settings:**
   - Click **Settings** (gear icon) in the left sidebar
   - Click **Database**

3. **Find Connection String:**
   - Scroll to **Connection string** section
   - Look for **URI** or **Connection pooling**
   - The password is embedded in the connection string

4. **Or Find Direct Password:**
   - Look for **Database password** section
   - Click **Reset database password** if you need to set a new one
   - The password will be shown (copy it immediately, it won't be shown again)

### Connection String Format:
```
postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres
```

**Example:**
```
postgresql://postgres:your_password_here@db.qnwsnrfcnonaxvnithfv.supabase.co:5432/postgres
```

---

## Method 2: Using Supabase API Keys (Recommended for Applications)

For application connections, use **API Keys** instead of database password:

### Where to Find API Keys:

1. **Go to Supabase Dashboard:**
   - Visit: https://app.supabase.com
   - Select your project

2. **Navigate to Settings → API:**
   - Click **Settings** → **API**
   - You'll see:
     - **Project URL** (SUPABASE_URL)
     - **anon/public key** (VITE_SUPABASE_PUBLISHABLE_KEY)
     - **service_role key** (SUPABASE_SERVICE_ROLE_KEY) - **Keep this secret!**

### Environment Variables:
```bash
# For frontend/application use
VITE_SUPABASE_URL=https://qnwsnrfcnonaxvnithfv.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=your_anon_key_here

# For backend/admin operations
SUPABASE_URL=https://qnwsnrfcnonaxvnithfv.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

---

## Method 3: Using Supabase SQL Editor (No Password Needed)

For running SQL scripts, you don't need a password:

1. **Go to Supabase Dashboard**
2. **Click SQL Editor** in the left sidebar
3. **Paste and run your SQL** - Authentication is handled automatically

This is the **recommended method** for executing the database implementation scripts.

---

## 🔑 Important Notes

### Database Password:
- **Location:** Settings → Database → Connection string
- **Format:** Embedded in PostgreSQL connection URI
- **Reset:** Can be reset in Settings → Database → Reset database password
- **Security:** Never commit passwords to git!

### API Keys:
- **Service Role Key:** Has admin privileges - **KEEP SECRET**
- **Anon Key:** Public key for client-side use
- **Location:** Settings → API

### Connection Methods:

| Method | Password Type | Use Case |
|--------|--------------|----------|
| Direct PostgreSQL | Database password | psql, pgAdmin, database tools |
| Supabase Client | API keys | Application code |
| SQL Editor | None (auto-auth) | Running SQL scripts |

---

## 🚀 Quick Connection Examples

### Using psql (Command Line):
```bash
psql "postgresql://postgres:[PASSWORD]@db.qnwsnrfcnonaxvnithfv.supabase.co:5432/postgres"
```

### Using Environment Variables:
```bash
# Create .env.local file
echo "SUPABASE_URL=https://qnwsnrfcnonaxvnithfv.supabase.co" > .env.local
echo "SUPABASE_SERVICE_ROLE_KEY=your_service_role_key" >> .env.local
```

### Using Supabase SQL Editor:
- No password needed - just log in to Supabase Dashboard
- Go to SQL Editor
- Paste and run SQL

---

## 📍 Project Information

- **Project ID:** `qnwsnrfcnonaxvnithfv`
- **Project Reference:** `qnwsnrfcnonaxvnithfv`
- **Database Host:** `db.qnwsnrfcnonaxvnithfv.supabase.co`
- **Database Port:** `5432`
- **Database Name:** `postgres`
- **Database User:** `postgres`

---

## ⚠️ Security Reminders

1. **Never commit passwords or API keys to git**
2. **Use environment variables** for sensitive credentials
3. **Service Role Key** has admin access - keep it secret
4. **Reset passwords** if they're ever exposed
5. **Use SQL Editor** for database scripts (safest method)

---

## 💡 For Database Implementation

**Recommended Approach:**
- Use **Supabase SQL Editor** (no password needed)
- Copy phase SQL files from `db-implementation-phases/`
- Paste and execute in SQL Editor
- This is the safest and easiest method

**Alternative:**
- Use direct PostgreSQL connection with database password
- Only if you need to use external tools like pgAdmin

---

**Need Help?**
- Supabase Docs: https://supabase.com/docs/guides/database/connecting-to-postgres
- Project Dashboard: https://app.supabase.com/project/qnwsnrfcnonaxvnithfv

