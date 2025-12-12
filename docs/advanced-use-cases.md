# Advanced Use Cases

This document provides real-world examples and advanced use cases for OpenCode, sourced from established projects and the awesome-opencode repository.

## Overview

This guide demonstrates advanced OpenCode capabilities through practical examples from production use and community projects.

## Multi-Agent Development Team

**Source:** [xTamasu/awesome-opencode](https://github.com/xTamasu/awesome-opencode)

### Architecture
A 14-agent virtual development team with specialized roles:

**Agent Roles:**
- **Project Manager** - Task breakdown and coordination
- **Senior Developer** - Architecture and complex implementations
- **AI Engineer** - ML/AI specific tasks
- **QA Engineer** - Testing and quality assurance
- **DevOps Engineer** - CI/CD and infrastructure
- **UI/UX Designer** - Interface design decisions
- **Database Architect** - Data modeling
- **Security Engineer** - Security analysis
- **Technical Writer** - Documentation
- **Code Reviewer** - PR reviews
- **Performance Engineer** - Optimization
- **Integration Specialist** - Third-party integrations
- **Research Engineer** - Technology evaluation
- **Support Engineer** - User issues and debugging

### Implementation Pattern

```jsonc
// opencode.jsonc
{
  "agents": {
    "pm": {
      "model": "claude-sonnet-4",
      "systemPrompt": "You are a project manager...",
      "tools": ["todowrite", "task"]
    },
    "senior-dev": {
      "model": "claude-opus-4",
      "systemPrompt": "You are a senior developer...",
      "tools": ["read", "write", "edit", "bash", "grep"]
    },
    "qa": {
      "model": "gpt-4",
      "systemPrompt": "You are a QA engineer...",
      "tools": ["bash", "read", "grep"]
    }
  }
}
```

### Workflow Example

```bash
# 1. PM breaks down task
opencode --agent pm "Create user authentication system"

# 2. Senior dev implements core logic
opencode --agent senior-dev "Implement JWT authentication"

# 3. QA runs tests
opencode --agent qa "Test authentication system"

# 4. Code review
opencode --agent reviewer "Review authentication PR"
```

### Complexity Tiers
- **Small** (< 100 LOC): Single agent
- **Medium** (100-500 LOC): 2-3 agents
- **Large** (500-2000 LOC): 4-6 agents
- **Mega** (> 2000 LOC): Full team

## Memory-First Development

**Pattern:** Search patterns and best practices before coding

### Knowledge Base Structure

```
.opencode/
├── knowledge/
│   ├── patterns/
│   │   ├── authentication.md
│   │   ├── api-design.md
│   │   └── error-handling.md
│   ├── decisions/
│   │   ├── adr-001-database-choice.md
│   │   └── adr-002-auth-strategy.md
│   └── examples/
│       ├── user-service.ts
│       └── api-routes.ts
```

### Configuration

```jsonc
{
  "context": {
    "autoInclude": true,
    "knowledgeBase": ".opencode/knowledge",
    "patterns": {
      "beforeCoding": [
        "Search knowledge base for similar patterns",
        "Review architectural decisions",
        "Check example implementations"
      ]
    }
  }
}
```

### Workflow

```bash
# Agent automatically searches KB before implementing
opencode "Implement user registration with email verification"

# Steps:
# 1. Search .opencode/knowledge/patterns/authentication.md
# 2. Review .opencode/knowledge/decisions/adr-002-auth-strategy.md
# 3. Reference .opencode/knowledge/examples/user-service.ts
# 4. Implement following established patterns
```

## Advanced Context Pruning

**Source:** [opencode-dynamic-context-pruning](https://github.com/awesome-opencode/awesome-opencode)

### Problem
Large codebases exceed context windows, causing:
- Incomplete analysis
- Missing critical dependencies
- High token costs

### Solution: Dynamic Pruning

```jsonc
{
  "plugins": {
    "opencode-dynamic-context-pruning": {
      "enabled": true,
      "config": {
        "strategy": "relevance-scoring",
        "maxContextSize": 150000,  // tokens
        "pruningRules": [
          {
            "type": "age-based",
            "olderThan": "7d",
            "weight": 0.3
          },
          {
            "type": "frequency",
            "minAccesses": 2,
            "weight": 0.4
          },
          {
            "type": "dependency",
            "directOnly": false,
            "weight": 0.5
          }
        ]
      }
    }
  }
}
```

### Algorithm

1. **Score files** by relevance (0-1)
2. **Prune** lowest scoring files
3. **Keep** critical files (current focus, direct deps)
4. **Refresh** scores on context changes

### Impact
- 60% reduction in context size
- 40% cost savings
- Maintains code quality

## Session Management & Collaboration

**Source:** [opencode-sessions](https://github.com/awesome-opencode/awesome-opencode)

### Features
- Save/restore sessions with full context
- Share sessions across team
- Session templates for common workflows
- Collaborative coding sessions

### Configuration

```jsonc
{
  "plugins": {
    "opencode-sessions": {
      "enabled": true,
      "config": {
        "storageLocation": "~/.opencode/sessions",
        "autoSave": true,
        "saveInterval": 300,  // seconds
        "templates": {
          "bug-fix": {
            "tools": ["grep", "read", "edit", "bash"],
            "context": ["error-logs", "related-tests"]
          },
          "feature": {
            "tools": ["read", "write", "edit", "task", "todowrite"],
            "context": ["api-docs", "design-specs"]
          }
        }
      }
    }
  }
}
```

### Usage

```bash
# Save current session
opencode session save feature-auth

# Load template
opencode session new --template bug-fix

# Share with team
opencode session share feature-auth --team backend

# Resume on different machine
opencode session resume feature-auth
```

## MCP Server Composition

**Pattern:** Single OpenCode server coordinating multiple MCP servers

### Architecture

```
┌──────────────────────────────┐
│   OpenCode (Single Server)   │
│  - Coordination              │
│  - Context Management        │
│  - Tool Routing              │
└──────────┬───────────────────┘
           │
    ┌──────┴───────┬─────────┬─────────┐
    │              │         │         │
┌───▼───┐   ┌─────▼──┐  ┌──▼───┐  ┌──▼────┐
│Files  │   │Database│  │Slack │  │GitHub │
│Server │   │Server  │  │Server│  │Server │
└───────┘   └────────┘  └──────┘  └───────┘
```

### Configuration

```jsonc
{
  "mcp": {
    // OpenCode coordinates these servers
    "filesystem": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "/workspace"],
      "priority": 1
    },
    "database": {
      "type": "local",
      "command": ["python", "-m", "mcp_server_postgres"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL}"
      },
      "priority": 2
    },
    "github": {
      "type": "remote",
      "url": "https://mcp-github.company.com",
      "headers": {
        "Authorization": "******"
      },
      "priority": 3
    }
  },
  "orchestration": {
    "singleServer": true,
    "coordinator": "opencode",
    "routing": {
      "strategy": "priority-based",
      "fallback": "round-robin"
    }
  }
}
```

### Benefits

1. **Single Context**: All tools share context
2. **Coordination**: OpenCode routes requests
3. **Efficiency**: Reduced overhead
4. **Simplicity**: One server to manage

## Continuous Experimentation

**Source:** [How We Use Claude Code Skills to Run 1,000+ ML Experiments a Day](https://huggingface.co/blog/sionic-ai/claude-code-skills-training)

### Setup

```
.agent/skills/
├── experiment-runner.md
├── data-preprocessing.md
├── model-training.md
└── results-analysis.md
```

### Experiment Runner Skill

```markdown
---
name: experiment-runner
description: Run ML experiments with tracking
triggers:
  - "run experiment"
  - "train model"
  - "compare models"
---

## Process

1. **Prepare Environment**
   - Load configuration
   - Set up tracking (MLflow/Weights & Biases)
   - Initialize experiment

2. **Data Pipeline**
   - Load and validate data
   - Apply preprocessing
   - Split train/val/test

3. **Training Loop**
   - Initialize model
   - Configure optimizer
   - Run training with callbacks
   - Log metrics

4. **Evaluation**
   - Run inference on test set
   - Calculate metrics
   - Generate plots

5. **Artifacts**
   - Save model checkpoint
   - Log parameters and results
   - Create summary report
```

### Usage

```bash
opencode "Run experiment with learning_rate=0.001 batch_size=32"

# OpenCode automatically:
# 1. Activates experiment-runner skill
# 2. Sets up tracking
# 3. Runs training
# 4. Logs results
# 5. Generates report
```

### Parallel Experiments

```jsonc
{
  "experiments": {
    "parallel": true,
    "maxConcurrent": 4,
    "grid": {
      "learning_rate": [0.001, 0.01, 0.1],
      "batch_size": [16, 32, 64],
      "optimizer": ["adam", "sgd"]
    }
  }
}
```

## Advanced Plugin: Roadmap Management

**Source:** [opencode-roadmap](https://github.com/awesome-opencode/awesome-opencode)

### Features
- Project-wide planning
- Milestone tracking
- Decision history
- Dependency mapping

### Structure

```
.opencode/roadmap/
├── roadmap.md
├── milestones/
│   ├── v1.0.md
│   └── v2.0.md
├── decisions/
│   ├── 001-architecture.md
│   └── 002-deployment.md
└── dependencies.json
```

### Plugin Configuration

```jsonc
{
  "plugins": {
    "opencode-roadmap": {
      "enabled": true,
      "config": {
        "roadmapPath": ".opencode/roadmap",
        "visualization": "mermaid",
        "autoUpdate": true,
        "integrations": {
          "github": {
            "syncIssues": true,
            "syncPRs": true
          },
          "jira": {
            "apiKey": "${JIRA_API_KEY}",
            "project": "PROJ"
          }
        }
      }
    }
  }
}
```

### Workflow

```bash
# View roadmap
opencode roadmap view

# Add milestone
opencode roadmap milestone add v1.5 "Feature complete"

# Record decision
opencode roadmap decision add "Use PostgreSQL for storage"

# Check dependencies
opencode roadmap deps check
```

## Google AI Search Integration

**Source:** [opencode-google-ai-search](https://github.com/awesome-opencode/awesome-opencode)

### Use Case
AI-powered web research during development

### Configuration

```jsonc
{
  "plugins": {
    "opencode-google-ai-search": {
      "enabled": true,
      "config": {
        "apiKey": "${GOOGLE_API_KEY}",
        "searchEngineId": "${SEARCH_ENGINE_ID}",
        "maxResults": 10,
        "autoSummarize": true,
        "cache": {
          "enabled": true,
          "ttl": 3600
        }
      }
    }
  }
}
```

### Examples

```bash
# Search during development
opencode "Find best practices for JWT token storage"

# Compare implementations
opencode "Compare React vs Vue for dashboard project"

# Find solutions
opencode "How to fix 'CORS error' in Express API"
```

## Gamified Development

**Source:** [opencode-warcraft-notifications](https://github.com/awesome-opencode/awesome-opencode)

### Features
- Achievement system
- XP for completed tasks
- Level progression
- Team leaderboards

### Configuration

```jsonc
{
  "plugins": {
    "opencode-warcraft-notifications": {
      "enabled": true,
      "config": {
        "soundEffects": true,
        "achievements": {
          "bugSlayer": {
            "trigger": "fix_bug",
            "count": 10,
            "reward": "Bug Slayer badge"
          },
          "testMaster": {
            "trigger": "write_test",
            "count": 50,
            "reward": "Test Master badge"
          }
        },
        "levels": {
          "junior": 0,
          "mid": 1000,
          "senior": 5000,
          "architect": 10000
        }
      }
    }
  }
}
```

## Performance Optimization Pattern

### Code Analysis & Optimization

```bash
# 1. Profile code
opencode "Profile the data processing pipeline"

# 2. Identify bottlenecks
opencode "Analyze performance metrics and identify bottlenecks"

# 3. Implement optimizations
opencode "Optimize the identified bottlenecks"

# 4. Benchmark
opencode "Run benchmarks and compare results"
```

### Automated Optimization

```jsonc
{
  "optimization": {
    "autoProfile": true,
    "thresholds": {
      "responseTime": 200,  // ms
      "memoryUsage": 512,   // MB
      "cpuUsage": 80        // %
    },
    "actions": {
      "onThresholdExceeded": [
        "profile",
        "analyze",
        "suggest_optimizations"
      ]
    }
  }
}
```

## Enterprise Deployment Pattern

### Multi-Environment Setup

```jsonc
{
  "environments": {
    "development": {
      "model": "gpt-3.5-turbo",
      "mcp": {
        "database": {
          "type": "local",
          "command": ["docker", "run", "postgres-dev"]
        }
      }
    },
    "staging": {
      "model": "claude-sonnet-4",
      "mcp": {
        "database": {
          "type": "remote",
          "url": "https://db-staging.company.com"
        }
      }
    },
    "production": {
      "model": "claude-opus-4",
      "security": {
        "requireApproval": true,
        "auditLog": true
      },
      "mcp": {
        "database": {
          "type": "remote",
          "url": "https://db-prod.company.com",
          "readOnly": true
        }
      }
    }
  }
}
```

### Deployment Workflow

```bash
# Switch environments
opencode --env development

# Deploy with checks
opencode deploy --env staging --dry-run
opencode deploy --env staging --approve
opencode deploy --env production --require-approval
```

## Key Takeaways

1. **Multi-Agent Systems** - Distribute work across specialized agents
2. **Knowledge Management** - Build and maintain pattern libraries
3. **Context Optimization** - Use dynamic pruning for large codebases
4. **Session Management** - Save and share development contexts
5. **MCP Orchestration** - Coordinate multiple servers efficiently
6. **Continuous Experimentation** - Automate ML workflows
7. **Enterprise Patterns** - Multi-environment deployments

## Next Steps

- Review [Migration Strategy](./migration-strategy.md) for adapting these patterns
- Check [Research Questions](./research-questions.md) for POC planning
- Explore [Plugins and Tools](./plugins-and-tools.md) for implementation details

## References

- [xTamasu/awesome-opencode](https://github.com/xTamasu/awesome-opencode) - Multi-agent teams
- [awesome-opencode/awesome-opencode](https://github.com/awesome-opencode/awesome-opencode) - Community plugins
- [Sionic AI Blog](https://huggingface.co/blog/sionic-ai/claude-code-skills-training) - ML experiments
