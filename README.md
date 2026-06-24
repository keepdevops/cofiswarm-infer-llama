# cofiswarm-infer-llama

Cofiswarm component: `infer-llama`.

- Layout: [REPO-STANDARD-LAYOUT](https://github.com/keepdevops/cofiswarm-docs/blob/main/REPO-STANDARD-LAYOUT.md)
- Migration: [MIGRATION-SPRINTS](https://github.com/keepdevops/cofiswarm-docs/blob/main/MIGRATION-SPRINTS.md)

## FHS paths

| Path | Purpose |
|------|---------|
| `/etc/cofiswarm/infer-llama/` | config |
| `/var/lib/cofiswarm/infer-llama/` | state |
| `/var/log/cofiswarm/infer-llama/` | logs |

## Test

```bash
./test/scripts/assert-layout.sh infer-llama
```
