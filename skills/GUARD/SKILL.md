---
name: GUARD
description: "Security & Deployment domain context. Threat model injection, language-specific
  threat detection, supply chain auditing, and deploy gate enforcement. C0RS0 executes
  with corsoTools action guard (includes path-based scanning, formerly security_scan)."
user-invocable: false
context: fork
agent: C0RS0
version: 5.0.0
---

# /GUARD — Security & Deployment Domain

> Build Phase 4/7: AUDIT — Scan for threats after code is linted, before testing

## Lifecycle Context

Follows **SNIFF** (detect code issues) -> feeds into **CHASE** (verify fixes pass tests).

The primary security and deployment entry point for C0RS0. Loads **threat modeling, vulnerability scanning, supply chain auditing, and deploy gate enforcement** context into C0RS0, which then executes directly using security MCP tools.

```
Claude -> loads GUARD context -> C0RS0 executes with guard tool
```

---

## Protocol

### Step 1: Gather Requirements (if spec is vague)

1. Gather security-specific context:
   - **Objective**: What to audit, scan, or secure?
   - **Scope**: Which project, modules, files, infrastructure?
   - **Compliance**: OWASP, SOC2, GDPR, HIPAA, or internal standards?
   - **Known concerns**: Prior findings, suspected vulnerabilities?
   - **Threat actors**: Internal, external, supply chain?
   - **Deploy target**: Cloud, on-prem, container, serverless?
2. Synthesize into a clear specification
3. Present spec for confirmation

### Step 2: Execute with MCP Tools

Use `mcp__C0RS0__corsoTools` with `action: "guard"` for comprehensive security analysis (includes path-based scanning), applying all threat intelligence context below.

---

## Quality Gates

### Pre-Execution
- [ ] Scope and objectives defined
- [ ] Threat model applied for target language
- [ ] Supply chain gate checklist included
- [ ] Deploy gate stages defined (if deployment scope)

### Post-Execution
- [ ] Security verdict: pass (zero HIGH/CRITICAL)
- [ ] Supply chain audit: zero critical/high CVEs
- [ ] No hardcoded secrets detected
- [ ] All acceptance criteria met

---

## Threat Model (from `security.rs:infer_threat_model`)

Scan code for these patterns and assess threat level:

| Pattern | Keywords | Threats |
|---------|----------|---------|
| Filesystem | `fs::`, `File::`, `open(`, `Path` | Path traversal, symlink attacks, TOCTOU |
| Network | `http`, `tcp`, `socket`, `TcpListener` | MITM, injection, DoS, SSRF |
| Unsafe | `unsafe`, `transmute`, `from_raw` | Memory corruption, UB, use-after-free |
| Command | `Command::new`, `exec`, `system(` | Command injection, privilege escalation |
| Deserialization | `serde`, `Deserialize`, `from_str` | Type confusion, denial of service |
| Cryptography | `rand`, `hash`, `encrypt`, `sign` | Weak algorithms, key exposure |
| Authentication | `token`, `session`, `auth`, `password` | Credential theft, session hijacking |

---

## Language-Specific Threats (from `security.rs`)

**Rust**:
- `.unwrap()` -> panic in production (DoS vector)
- Integer overflow -> `checked_*` required
- `unsafe` blocks -> must have `// SAFETY:` justification
- `transmute` -> almost always wrong, audit carefully
- Raw pointer dereference -> prove aliasing rules satisfied

**JavaScript**:
- `innerHTML`, `document.write` -> XSS
- `eval()`, `Function()` -> code injection
- `__proto__`, `prototype` -> prototype pollution
- `JSON.parse` on untrusted input -> DoS via large payloads

**Python**:
- `eval()`, `exec()` -> code injection
- `pickle.loads()` -> arbitrary code execution
- f-strings with user input -> injection
- `os.system()`, `subprocess` without shell=False -> command injection
- SQL string formatting -> SQL injection (use parameterized queries)

**Go**:
- `defer` in loops -> resource leaks
- Goroutine leaks -> unbounded goroutine creation
- `unsafe.Pointer` -> memory corruption

---

## Supply Chain Gate (from Gold Standard S12)

| Check | Requirement | Blocking |
|-------|------------|----------|
| `cargo audit` | Zero critical/high CVEs | Yes |
| Dependency freshness | Updated within 12 months | Warning |
| License whitelist | MIT, Apache-2.0, BSD only | Yes |
| Lockfile committed | `Cargo.lock` in version control | Yes |
| Minimal deps | Prefer std library over crates | Advisory |

---

## Deploy Gate (from `infrastructure.rs`)

**CI/CD Pipeline Stages**:
1. Source control trigger (git push, PR)
2. Build (language-specific compilation)
3. Test suite (unit + integration)
4. Lint / format check
5. **Security scan** (SAST, dependency audit)
6. Container build (if applicable)
7. Registry push
8. Deploy to staging
9. Health check
10. Deploy to production
11. Monitoring enabled

**Container Security**:
- Multi-stage Docker builds (minimize attack surface)
- Non-root user in container
- No secrets in image layers
- Pin base image versions (no `latest` tag)
- Scan container images for CVEs

**Secrets Management**:
- Use `corsoTools` action: `guard` secrets mode
- Never hardcode API keys, tokens, passwords
- Environment variables or secrets manager only
- Rotate credentials regularly
- Audit access logs

---

## Coding Violations to Report

| Violation | Severity | Rule |
|-----------|----------|------|
| `.unwrap()` in production | HIGH | no-unwrap |
| `.expect()` in production | HIGH | no-expect |
| `panic!()` macro | HIGH | no-panic |
| `unsafe` without `// SAFETY:` | HIGH | unsafe-comment |
| Hardcoded secrets | CRITICAL | no-secrets |
| SQL string concatenation | CRITICAL | sql-injection |
| `eval()` / `exec()` | CRITICAL | no-eval |
| Missing input validation | MEDIUM | input-validation |
| Unbounded loop | MEDIUM | bounded-loops |
| Missing error handling | MEDIUM | handle-errors |

---

## Cross-Domain Context

| When | Skill Context | MCP Tools |
|------|--------------|-----------|
| Security findings need code fixes | SNIFF (review) / HUNT (generation) | `corsoTools` actions: `code_review`, `sniff` |
| Fixes need regression testing | CHASE | `corsoTools` action: `chase` |
| Researching CVEs, security advisories | FETCH | `corsoTools` action: `fetch` |

---

## MCP Tools Available

| `corsoTools` Action | Purpose |
|---------------------|---------|
| `guard` | Security analysis (4,997 vulnerability patterns) + path-based scanning |
