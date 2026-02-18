# Supabase CLI Fix - Architecture Mismatch

**Error:** `zsh: bad CPU type in executable: supabase`

**Cause:** Supabase CLI was installed for wrong CPU architecture (Intel vs Apple Silicon)

---

## ✅ Quick Fix

### Option 1: Run Fix Script (Recommended)

```bash
./scripts/fix-supabase-cli.sh
```

This will:
1. Detect your CPU architecture
2. Remove old Supabase CLI
3. Install correct version for your system
4. Verify installation

### Option 2: Manual Fix via Homebrew

```bash
# Uninstall old version
brew uninstall supabase

# Install correct version
brew install supabase/tap/supabase

# Verify
supabase --version
```

### Option 3: Manual Fix via npm

```bash
# Uninstall old version
npm uninstall -g supabase

# Install correct version
npm install -g supabase

# Verify
supabase --version
```

---

## 🔍 Check Your Architecture

```bash
# Check CPU architecture
uname -m

# Output:
# - arm64 = Apple Silicon (M1/M2/M3) - needs arm64 binary
# - x86_64 = Intel Mac - needs amd64 binary
```

---

## 📝 Alternative: Use Supabase Dashboard

You don't need the CLI! You can do everything via the Dashboard:

### Link Project (via Dashboard):

1. **Go to Supabase Dashboard:**
   - Visit: https://supabase.com/dashboard
   - Select project: `YOUR_SUPABASE_PROJECT_ID`

2. **Run SQL Scripts:**
   - Go to: **SQL Editor** → **New Query**
   - Paste and run your SQL scripts

3. **Manage Migrations:**
   - Go to: **Database** → **Migrations**
   - Or: **SQL Editor** → **Migrations**

4. **Seed Data:**
   - Go to: **SQL Editor** → **New Query**
   - Run: `scripts/seed-production-data.sql`

---

## 🚀 After Fixing CLI

Once Supabase CLI is working:

```bash
# Link to your project
supabase link --project-ref YOUR_SUPABASE_PROJECT_ID

# Or if you have a local config
supabase link --project-ref YOUR_SUPABASE_PROJECT_ID --password YOUR_DB_PASSWORD
```

---

## 🔧 Troubleshooting

### Issue: Still getting "bad CPU type"

**Solution:**
1. Check architecture: `uname -m`
2. Remove all Supabase installations:
   ```bash
   brew uninstall supabase
   npm uninstall -g supabase
   rm -f /usr/local/bin/supabase
   rm -f ~/.local/bin/supabase
   ```
3. Reinstall for correct architecture

### Issue: "Command not found" after install

**Solution:**
1. Check if in PATH:
   ```bash
   which supabase
   ```
2. Add to PATH if needed:
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```
3. Add to `~/.zshrc` for persistence:
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

### Issue: Permission denied

**Solution:**
```bash
# If installed to /usr/local/bin, may need sudo
sudo chmod +x /usr/local/bin/supabase

# Or install to user directory
mkdir -p ~/.local/bin
# Then add to PATH
```

---

## 💡 Recommendation

**For this project, you don't need Supabase CLI!**

You can do everything via the Supabase Dashboard:
- ✅ Run SQL scripts
- ✅ Manage migrations
- ✅ Seed data
- ✅ Configure OAuth
- ✅ View data

The CLI is optional and mainly useful for:
- Local development with Supabase
- Automated deployments
- Migration management

---

## ✅ Quick Checklist

- [ ] Run fix script: `./scripts/fix-supabase-cli.sh`
- [ ] Or use Supabase Dashboard instead
- [ ] Verify: `supabase --version`
- [ ] Link project: `supabase link --project-ref YOUR_SUPABASE_PROJECT_ID`

---

**The Dashboard is often easier than the CLI!** 🚀


