---
name: sequential-thinking
description: >
  Apply step-by-step structured reasoning for complex problems with revision
  capability. Use for multi-step debugging, architecture decisions, dependency
  analysis, and problems where scope is unclear upfront.
argument-hint: "[problem to analyze step-by-step]"
---

# sequential-thinking — Structured Reasoning

Structured problem-solving via manageable, reflective thought sequences with
dynamic adjustment. Activated internally by planner and debug skills.

## When to Apply

- Complex build/runtime errors with multiple possible causes
- Architecture decisions with trade-offs (e.g. client vs server component)
- Multi-step Supabase schema design
- Dependency conflicts in `package.json`
- Any problem where the solution path is not obvious upfront

## Core Process

### 1. Start with Loose Estimate
```
Thought 1/5: [Initial analysis]
```
Adjust total dynamically as understanding evolves.

### 2. Structure Each Thought
- Build on previous context explicitly
- Address one aspect per thought
- State assumptions and uncertainties
- Signal what the next thought should address

### 3. Apply Dynamic Adjustment
- **Expand**: More complexity found → increase total
- **Contract**: Simpler than expected → decrease total
- **Revise**: New insight invalidates earlier thought → mark revision
- **Branch**: Multiple valid approaches → explore both

### 4. Revision Format
```
Thought 5/8 [REVISION of Thought 2]: [Corrected understanding]
- Original: [what was stated]
- Why revised: [new insight]
- Impact: [what changes downstream]
```

### 5. Branch Format
```
Thought 4/7 [BRANCH A]: [Approach A — faster, less flexible]
Thought 4/7 [BRANCH B]: [Approach B — more setup, more scalable]
Decision: [which branch and why]
```

### 6. Final Thought
Mark as: `Thought N/N [FINAL]`

Complete only when:
- Solution is verified or decision is made
- All critical aspects addressed
- No blocking uncertainties remain

## Application Modes

**Explicit**: Use visible thought markers when user benefits from seeing reasoning
or when debugging a complex error with the user watching.

**Implicit**: Apply methodology internally for routine decisions without cluttering
the response — just produce the correct output.
