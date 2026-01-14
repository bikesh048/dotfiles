# LSP & Tools

## Language Servers

| LSP | Languages | Features |
|-----|-----------|----------|
| `ts_ls` | JavaScript, TypeScript | Completions, diagnostics, refactoring |
| `eslint` | JavaScript, TypeScript | Linting integration |
| `lua_ls` | Lua | Neovim config support |
| `yamlls` | YAML | Schema validation, completions |
| `ansiblels` | Ansible | Playbook support |
| `terraformls` | Terraform | HCL support |
| `dockerls` | Dockerfile | Docker syntax support |
| `docker_compose_language_service` | Docker Compose | Compose file support |

## YAML Schemas

The YAML language server is configured with schemas for:

| File Pattern | Schema |
|--------------|--------|
| `.github/workflows/*` | GitHub Actions |
| `action.yml` | GitHub Action |
| `k8s/**/*.yml` | Kubernetes resources |
| `kustomization.yaml` | Kustomize |
| `Chart.yaml` | Helm Chart |
| `playbooks/*.yml` | Ansible Playbooks |
| `.gitlab-ci.yml` | GitLab CI |
| `docker-compose*.yml` | Docker Compose |
| `package.json` | NPM Package |
| `.prettierrc` | Prettier config |
| `.eslintrc` | ESLint config |

## Formatters (Conform.nvim)

| Filetype | Formatter |
|----------|-----------|
| `lua` | stylua |
| `javascript`, `typescript`, `tsx`, `jsx` | prettierd / prettier |
| `json`, `yaml`, `markdown`, `css`, `scss` | prettierd / prettier |
| `html`, `erb` | htmlbeautifier |
| `bash`, `sh` | beautysh |
| `proto` | buf |
| `toml` | taplo |
| `xml` | xmllint |

## Linters (nvim-lint)

| Filetype | Linter |
|----------|--------|
| `javascript`, `typescript`, `tsx`, `jsx` | eslint_d |
| `svelte` | eslint_d |
| `yaml` | yamllint |
| `yaml.ansible` | ansible_lint |

## Treesitter Parsers

Installed parsers for syntax highlighting:

- `javascript`, `typescript`, `tsx`
- `lua`, `vim`, `vimdoc`, `query`
- `json`, `yaml`, `toml`
- `html`, `css`, `markdown`
- `dockerfile`, `terraform`
- `bash`, `regex`
- `astro`, `jq`

## Mason-Installed Tools

Tools automatically installed via Mason:

**Formatters:**
- prettier, prettierd, stylua
- htmlbeautifier, beautysh, buf

**Linters:**
- eslint_d, shellcheck

**LSP Servers:**
- astro-language-server
- ansible-language-server
- yaml-language-server

## Manual Installation Required

Some tools need manual installation:

```bash
# Via Homebrew (more reliable than Mason for Python tools)
brew install yamllint ansible-lint

# Verify installation
yamllint --version
ansible-lint --version
```

## Ansible File Detection

Files are automatically detected as Ansible based on path patterns:

- `*/playbooks/*.yml`
- `*/roles/*/tasks/*.yml`
- `*/roles/*/handlers/*.yml`
- `*/roles/*/defaults/*.yml`
- `*/roles/*/vars/*.yml`
- `*/inventory/*.yml`
- `*/group_vars/*.yml`
- `*/host_vars/*.yml`
- `*ansible*.yml`

## Useful Commands

```vim
:Mason          " Open Mason UI to manage tools
:LspInfo        " Show active LSP for current buffer
:LspLog         " View LSP logs
:TSInstallInfo  " Show installed Treesitter parsers
:ConformInfo    " Show formatter for current buffer
```
