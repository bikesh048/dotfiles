# PHP Support in Neovim

Complete setup guide for PHP development in Neovim.

## Overview

PHP support includes:
- ✅ **LSP:** Intelephense (autocomplete, go to definition, diagnostics)
- ✅ **Formatter:** PHP-CS-Fixer (PSR-12 code formatting)
- ✅ **Linter:** PHPCS (code style checking)

---

## Installation

### 1. Restart Neovim and Sync Plugins

```vim
:Lazy sync
```

Wait for it to complete, then restart Neovim.

### 2. Install PHP Tools via Mason

**In Neovim:**
```vim
:Mason
```

Search and install:
- ✅ `intelephense` (LSP server) - Should auto-install
- ✅ `php-cs-fixer` (Formatter)
- ✅ `phpcs` (Linter)

**Or install via command:**
```vim
:MasonInstall intelephense php-cs-fixer phpcs
```

### 3. System Dependencies (Optional)

**Via Homebrew:**
```bash
brew install php composer
```

---

## Features

### 1. **LSP (Intelephense) - Code Intelligence**

Provides:
- 🔍 **Autocomplete** - Class names, methods, variables
- 📖 **Hover Documentation** - Press `K` on any symbol
- 🎯 **Go to Definition** - Press `gd` to jump to function/class
- 🔎 **Find References** - `<leader>vrr` to see all usages
- ✏️ **Rename Symbol** - `<leader>rn` to rename across project
- 💡 **Code Actions** - `<leader>vca` for quick fixes

**Keymaps:**
| Key | Action | Example |
|-----|--------|---------|
| `gd` | Go to definition | Cursor on `TripController` → `gd` → Jumps to class |
| `K` | Show hover documentation | Cursor on function → `K` → See docs |
| `<leader>rn` | Rename symbol | Cursor on variable → `<leader>rn` → Rename everywhere |
| `<leader>vca` | Code actions | `<leader>vca` → Show quick fixes |
| `<leader>vrr` | Find references | Find all places class/function is used |
| `[d` / `]d` | Next/prev diagnostic | Jump to errors/warnings |
| `<leader>vd` | Show diagnostic | See error details |

### 2. **Formatter (PHP-CS-Fixer)**

Auto-formats PHP code to PSR-12 standard.

**Usage:**
```vim
" Format current file
<leader>l

" Format selected code (visual mode)
Select code → <leader>l
```

**What it fixes:**
- Indentation and spacing
- PSR-12 coding standard
- Braces placement
- Import statements
- Trailing whitespace

**Example:**
```php
// Before
<?php
function test(){
$x=1;
  echo $x;
}

// After pressing <leader>l
<?php

function test()
{
    $x = 1;
    echo $x;
}
```

### 3. **Linter (PHPCS)**

Checks code style and detects errors.

**Usage:**
```vim
" Lint runs automatically on:
- File open (BufEnter)
- File save (BufWritePost)
- Leaving insert mode (InsertLeave)

" Manual lint:
<leader>ll
```

**What it checks:**
- PSR-12 coding standards
- Variable naming conventions
- Function complexity
- Missing docblocks

---

## Common Use Cases

### Navigate to Class/Method

**Example: Laravel Route**
```php
Route::post('/generate-slug', [TripController::class, 'generateSlug']);
```

**Navigate to class:**
1. Put cursor on `TripController`
2. Press `gd`
3. Jumps to `app/Http/Controllers/TripController.php`

**Navigate to method:**
1. Put cursor on `'generateSlug'`
2. Press `gd`
3. Jumps to the method in the controller

**Jump back:**
- `Ctrl + o` - Back to previous location
- `Ctrl + i` - Forward

---

### Rename Function Across Project

```php
// In UserController.php
public function getUserData() {
    return $this->user;
}
```

**Steps:**
1. Cursor on `getUserData`
2. Press `<leader>rn`
3. Type new name: `fetchUserData`
4. Press Enter
5. ✅ Renamed everywhere in project!

---

### Auto-format Messy Code

```php
// Write messy code:
<?php
class User{
private $name;public function getName(){return $this->name;}
}

// Press <leader>l → Auto-formats to:
<?php

class User
{
    private $name;

    public function getName()
    {
        return $this->name;
    }
}
```

---

### Find All Class Usages

**Example: Find where `User` model is used**

```php
use App\Models\User;
```

**Steps:**
1. Cursor on `User`
2. Press `<leader>vrr`
3. Telescope opens with all references
4. Navigate with `Ctrl-j/k`
5. Press Enter to jump to file

---

### Get Autocomplete

**Start typing:**
```php
<?php

$user = new User();
$user->  // ← Autocomplete popup appears!
```

Shows all available methods:
- `getName()`
- `getEmail()`
- `save()`
- etc.

**Navigate autocomplete:**
- `Ctrl-n` - Next suggestion
- `Ctrl-p` - Previous suggestion
- `Enter` - Accept
- `Ctrl-Space` - Trigger manually

---

## Project Configuration (Optional)

### PHP-CS-Fixer Config

Create `.php-cs-fixer.php` in project root:

```php
<?php

return (new PhpCsFixer\Config())
    ->setRules([
        '@PSR12' => true,
        'array_syntax' => ['syntax' => 'short'],
        'ordered_imports' => ['sort_algorithm' => 'alpha'],
        'no_unused_imports' => true,
    ])
    ->setFinder(
        PhpCsFixer\Finder::create()
            ->exclude('vendor')
            ->in(__DIR__)
    );
```

### PHPCS Config

Create `phpcs.xml` in project root:

```xml
<?xml version="1.0"?>
<ruleset name="Custom">
    <description>Custom PHP coding standard</description>

    <rule ref="PSR12"/>

    <exclude-pattern>*/vendor/*</exclude-pattern>
    <exclude-pattern>*/node_modules/*</exclude-pattern>

    <arg value="p"/>
    <arg value="s"/>
    <arg name="colors"/>
</ruleset>
```

---

## Troubleshooting

### Issue: `gd` doesn't work

**Check LSP status:**
```vim
:LspInfo
```

**Should see:**
```
Client: intelephense (id: 1)
filetypes: php
root directory: /path/to/project
```

**Fixes:**
1. Restart LSP: `:LspRestart`
2. Reinstall: `:MasonUninstall intelephense` then `:MasonInstall intelephense`
3. Restart Neovim

---

### Issue: No autocomplete

**Intelephense works best with composer.json**

Create minimal `composer.json`:
```json
{
    "require": {
        "php": "^8.0"
    }
}
```

Then restart Neovim in that directory.

---

### Issue: Formatter not found

**Check Mason:**
```vim
:Mason
```

Find `php-cs-fixer` and install it.

**Or check system:**
```bash
which php
php --version
```

Need PHP 7.4+ installed.

---

### Issue: Too many lint errors

**Temporarily disable:**
```vim
:lua require('lint').linters_by_ft.php = {}
```

**Or configure phpcs.xml to ignore rules** (see configuration section above)

---

## Laravel-Specific Tips

### Navigate Routes → Controllers

```php
// routes/web.php
Route::get('/users', [UserController::class, 'index']);
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                     Cursor here → gd → Jump to controller
```

### Use Telescope to Find Routes

```vim
Space + f + g
Type: Route::get
```

See all routes in project!

### Find Model Usage

```vim
Space + f + g
Type: User::find
```

See everywhere a model is queried.

---

## Quick Reference Card

### Navigation
```
gd                → Go to definition
K                 → Hover documentation
<leader>vrr       → Find references
<leader>rn        → Rename symbol
Ctrl + o          → Jump back
Ctrl + i          → Jump forward
```

### Formatting & Linting
```
<leader>l         → Format file/selection
<leader>ll        → Manual lint
```

### Autocomplete
```
Ctrl-n            → Next suggestion
Ctrl-p            → Previous suggestion
Ctrl-Space        → Trigger manually
Enter             → Accept
```

### Mason
```
:Mason            → Open Mason UI
:LspInfo          → Check LSP status
:LspRestart       → Restart LSP
:ConformInfo      → Check formatter
```

---

## File Structure

Configuration files:

```
nvim/.config/nvim/
├── lua/
│   └── plugins/
│       ├── lsp.lua         ← Intelephense config (line 64)
│       ├── conform.lua     ← PHP-CS-Fixer config (line 32)
│       └── lint.lua        ← PHPCS config (line 18)
```

---

## Standards

**PSR-12 Key Rules:**
- 4 spaces for indentation (no tabs)
- Opening braces for classes/functions on new line
- No trailing whitespace
- Files must end with newline
- Max 120 characters per line (soft limit)

**Resources:**
- [PSR-12 Standard](https://www.php-fig.org/psr/psr-12/)
- [PHP The Right Way](https://phptherightway.com/)

---

## Next Steps

1. ✅ Restart Neovim
2. ✅ Run: `:Lazy sync`
3. ✅ Install tools: `:MasonInstall intelephense php-cs-fixer phpcs`
4. ✅ Open a PHP file
5. ✅ Test navigation:
   - Type class name → `gd`
   - Hover function → `K`
   - Format code → `<leader>l`

---

## Related Documentation

- [Neovim Keymaps](./nvim-keymaps.md) - All keybindings
- [LSP & Tools](./lsp-tools.md) - Language server guide
- [Telescope Guide](./telescope-guide.md) - Search & navigation
