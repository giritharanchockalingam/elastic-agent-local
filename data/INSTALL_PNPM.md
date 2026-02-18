# Installing pnpm

## Option 1: Install pnpm using standalone script (Recommended)

```bash
curl -fsSL https://get.pnpm.io/install.sh | sh -
```

After installation, restart your terminal or run:
```bash
source ~/.zshrc
```

## Option 2: Use npm with npx (No installation needed)

You can use npm directly instead of pnpm:

```bash
# Install dependencies
npm install

# Run harvester
npm run harvest:thangamgrand:npm -- --tenant <tenantId> --property <propertyId> --dry-run
```

## Option 3: Install pnpm with Homebrew (macOS)

```bash
brew install pnpm
```

## Option 4: Use npm directly (Update scripts)

If you prefer to use npm, you can update the scripts in `package.json`:

```json
{
  "scripts": {
    "harvest:thangamgrand": "npx tsx scripts/harvest-and-rewrite-property-site.ts"
  }
}
```

Then run:
```bash
npm run harvest:thangamgrand -- --tenant <tenantId> --property <propertyId> --dry-run
```

## Quick Test After Installation

```bash
pnpm --version
# Should show version number like: 9.0.0
```

