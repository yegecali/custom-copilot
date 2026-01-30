# Agent Orchestration for Spring to Quarkus Migration

**Version:** 1.0  
**Date:** 30 de enero de 2026  
**Purpose:** Define how the migration agent orchestrates and controls the complete migration process

---

## 🎭 Orchestration Overview

The agent acts as a **migration conductor** that:

- ✅ Coordinates all migration phases
- ✅ Manages execution flow and decisions
- ✅ Validates progress at each step
- ✅ Provides guidance and corrections
- ✅ Tracks overall migration status

---

## 📊 Agent Responsibilities

### Phase Control

- Determine current phase
- Execute phase-specific instructions
- Validate phase completion
- Transition to next phase

### Resource Management

- Apply correct instructions from `.github/instructions/`
- Use relevant prompts from `.github/prompts/`
- Execute skills from `.github/skills/`
- Reference examples from README.md

### Quality Gates

- Verify compilation after each phase
- Validate against checklists
- Check code patterns match templates
- Ensure no Spring/RxJava dependencies remain

### User Guidance

- Provide clear next steps
- Explain what should happen
- Show expected results
- Offer troubleshooting help

---

## 🔄 Migration Orchestration Flow

```
START
  ↓
[PHASE 1] PREPARATION
  ├─ Check prerequisites
  ├─ Verify original-spring/ exists
  ├─ Read project structure
  └─ Generate MIGRATION_PLAN.md
  ↓
[PHASE 2] QUARKUS BASE SETUP
  ├─ Execute: skill/01-quarkus-setup-skill.md
  ├─ Create pom.xml
  ├─ Create directory structure
  ├─ Create application.properties
  └─ Validate: mvn clean compile
  ↓
[PHASE 3] MIGRATE DEPENDENCIES
  ├─ List all Spring dependencies
  ├─ Remove Spring starters
  ├─ Add Quarkus extensions
  ├─ Check pom.xml structure
  └─ Validate: mvn dependency:tree
  ↓
[PHASE 4] OPENAPI INTEGRATION
  ├─ Execute: skill/03-openapi-generation-skill.md
  ├─ Copy openapi.yaml
  ├─ Configure Maven plugin
  ├─ Generate DTOs
  └─ Validate: src/main/java has generated classes
  ↓
[PHASE 5] RETROFIT → REST CLIENT
  ├─ Execute: skill/02-retrofit-migration-skill.md
  ├─ Use: prompts/retrofit-migration-prompt.md
  ├─ Identify all Retrofit interfaces
  ├─ Create REST Client interfaces
  ├─ Configure in application.properties
  └─ Validate: @RegisterRestClient present
  ↓
[PHASE 6] REACTIVE STACK (RxJava → Mutiny)
  ├─ Use: prompts/reactive-stack-prompt.md
  ├─ Identify Observable usage
  ├─ Convert to Uni<T>
  ├─ Remove subscribeOn/observeOn
  ├─ Add error handling
  └─ Validate: No Observable found
  ↓
[PHASE 7] SERVICES & LOGIC
  ├─ Use: instructions/05-CONFIGURATION.md
  ├─ Convert @Service → @ApplicationScoped
  ├─ Convert @Autowired → @Inject
  ├─ Migrate bean configurations
  ├─ Update property mappings
  └─ Validate: No Spring annotations
  ↓
[PHASE 8] REST ENDPOINTS
  ├─ Use: instructions/02-RETROFIT-MIGRATION.md (endpoint section)
  ├─ Convert @RestController → @Path
  ├─ Convert @RequestMapping → @Path
  ├─ Convert HTTP method annotations
  ├─ Ensure Uni<T> returns
  └─ Validate: All endpoints compile
  ↓
[PHASE 9] TESTING
  ├─ Use: instructions/06-TESTING.md
  ├─ Create @QuarkusTest test classes
  ├─ Use Rest Assured for HTTP testing
  ├─ Mock REST Client interfaces
  ├─ Run test suite
  └─ Validate: Tests > 80% coverage, all passing
  ↓
[PHASE 10] VALIDATION & FINAL
  ├─ mvn clean package
  ├─ Verify JAR size < 100MB
  ├─ mvn quarkus:dev
  ├─ Test all endpoints
  ├─ Check startup time < 2s
  ├─ Check memory < 200MB
  ├─ Validate OpenAPI/Swagger
  └─ Update MIGRATION_CHECKLIST.md
  ↓
END - Migration Complete ✅
```

---

## 🔍 Phase Execution Details

### PHASE 1: PREPARATION

**Agent Actions:**

```
1. Verify prerequisites
   - Check Java 17+ installed
   - Check Maven 3.8.1+ installed
   - Check Git available

2. Analyze original project
   - Read original-spring/pom.xml
   - Count Spring dependencies
   - Identify Retrofit interfaces
   - Locate OpenAPI contract
   - Check for RxJava usage

3. Create plan
   - Generate MIGRATION_PLAN.md
   - List all files to migrate
   - Estimate effort per component
   - Report findings

4. User validation
   - "Is the analysis correct? (yes/no)"
   - Ask clarification on complex cases
   - Proceed when confirmed
```

**Required Files:**

- `.github/instructions/01-MIGRATION-OVERVIEW.md`
- `spring-quarkus-migration/original-spring/` (user provides)

**Success Criteria:**

- ✅ Project structure understood
- ✅ All dependencies documented
- ✅ Migration plan created
- ✅ OpenAPI contract located

---

### PHASE 2: QUARKUS BASE SETUP

**Agent Actions:**

```
1. Execute skill
   - Follow `.github/skills/01-quarkus-setup-skill.md`
   - Create directory structure
   - Generate pom.xml with BOM
   - Create application.properties base

2. Validate structure
   mvn clean compile

3. Report status
   - "Quarkus base created successfully"
   - Show directory structure
   - Confirm compilation passed
```

**Required Files:**

- `.github/skills/01-quarkus-setup-skill.md`
- pom.xml template (provided in skill)

**Success Criteria:**

- ✅ Directory structure created
- ✅ pom.xml valid
- ✅ `mvn clean compile` passes
- ✅ No errors in IDE

---

### PHASE 3: DEPENDENCIES MIGRATION

**Agent Actions:**

```
1. Update pom.xml
   - Remove all Spring starters
   - Remove retrofit2 dependencies
   - Remove rxjava dependencies
   - Add Quarkus extensions:
     * quarkus-resteasy-reactive
     * quarkus-rest-client-reactive
     * quarkus-mutiny
     * quarkus-smallrye-openapi
     * quarkus-junit5
     * rest-assured

2. Validate
   mvn clean install

3. Check for conflicts
   - Ensure no version conflicts
   - Verify transitive dependencies
   - Report any issues
```

**Required Files:**

- `.github/instructions/01-MIGRATION-OVERVIEW.md` (dependency section)

**Success Criteria:**

- ✅ No Spring dependencies in pom.xml
- ✅ All Quarkus extensions present
- ✅ `mvn clean install` passes
- ✅ No dependency conflicts

---

### PHASE 4: OPENAPI INTEGRATION

**Agent Actions:**

```
1. Execute skill
   - Follow `.github/skills/03-openapi-generation-skill.md`
   - Copy openapi.yaml/json from original
   - Configure Maven openapi-generator plugin
   - Set generation paths

2. Generate
   mvn clean generate-sources

3. Validate
   - Check DTOs generated in target/
   - Verify classes are accessible
   - No generation errors

4. Move to source
   - Copy generated classes to src/main/java
   - Update package structure if needed
```

**Required Files:**

- `.github/skills/03-openapi-generation-skill.md`
- `original-spring/openapi.yaml` (from user project)

**Success Criteria:**

- ✅ openapi.yaml copied
- ✅ Maven plugin configured
- ✅ DTOs generated successfully
- ✅ Classes in src/main/java
- ✅ IDE recognizes classes

---

### PHASE 5: RETROFIT → REST CLIENT

**Agent Actions:**

```
1. Identify interfaces
   - Find all @GET, @POST, @PUT, @DELETE interfaces
   - List all @Query, @Path, @Body parameters
   - Document return types

2. For each interface
   - Create corresponding REST Client interface
   - Change Observable<T> → Uni<T>
   - Apply retrofit-migration-prompt.md
   - Add @RegisterRestClient
   - Add @Path, @Produces, @Consumes

3. Configure client
   - Add to application.properties:
     quarkus.rest-client.{configKey}.url=...
   - Add timeout/retry config

4. Validate
   mvn clean compile
   - No Observable found
   - All interfaces have @RegisterRestClient
   - All methods return Uni<T>
```

**Required Files:**

- `.github/instructions/02-RETROFIT-MIGRATION.md`
- `.github/prompts/retrofit-migration-prompt.md`
- `.github/skills/02-retrofit-migration-skill.md`
- README.md (Example 1: Servicio Simple)

**Success Criteria:**

- ✅ All interfaces migrated
- ✅ @RegisterRestClient present
- ✅ Uni<T> return types
- ✅ application.properties configured
- ✅ Compilation successful

---

### PHASE 6: REACTIVE STACK (RxJava → Mutiny)

**Agent Actions:**

```
1. Identify Observable usage
   - Find all Observable<T> in services
   - Find all .subscribe() calls
   - Find all subscribeOn/observeOn

2. For each Observable
   - Change Observable<T> → Uni<T>
   - Remove subscribeOn/observeOn
   - Apply reactive-stack-prompt.md
   - Use .map() instead of direct transformations
   - Use .flatMap() for chaining

3. Error handling
   - Change .onError() → .onFailure()
   - Change .timeout() → .ifNoItem().after()
   - Apply retry patterns

4. Validate
   grep -r "Observable" src/
   grep -r "subscribeOn" src/
   - Both should return NOTHING
```

**Required Files:**

- `.github/instructions/04-REACTIVE-STACK.md`
- `.github/prompts/reactive-stack-prompt.md`
- README.md (Example 2: Error Handling)

**Success Criteria:**

- ✅ No Observable found
- ✅ No subscribeOn/observeOn
- ✅ All methods return Uni<T>
- ✅ Error handling implemented
- ✅ Compilation successful

---

### PHASE 7: SERVICES & CONFIGURATION

**Agent Actions:**

```
1. Update services
   - Change @Service → @ApplicationScoped
   - Change @Autowired → @Inject
   - Add @RestClient to REST client injection
   - Update all method signatures (Observable → Uni)

2. Update configuration
   - Change @Configuration → @ApplicationScoped
   - Change @Bean methods (if any)
   - Migrate property mappings

3. Update properties
   - Change spring.* → quarkus.*
   - Add quarkus.rest-client.* configs
   - Set profiles (dev, prod, test)

4. Validate
   mvn clean compile
   - No @Autowired found
   - No @Service found (services are @ApplicationScoped)
   - All properties use quarkus.* prefix
```

**Required Files:**

- `.github/instructions/05-CONFIGURATION.md`
- README.md (Fase 7: Configuración)

**Success Criteria:**

- ✅ No Spring annotations
- ✅ CDI annotations present
- ✅ Properties migrated
- ✅ Profiles configured
- ✅ Compilation successful

---

### PHASE 8: REST ENDPOINTS

**Agent Actions:**

```
1. Update endpoints
   - Change @RestController → @Path
   - Change @RequestMapping → @Path
   - Change @GetMapping → @GET
   - Change @RequestParam → @QueryParam
   - Change @PathVariable → @PathParam
   - Remove @RequestBody (direct parameter)

2. For each endpoint
   - Ensure returns Uni<T>
   - Add @Produces/@Consumes
   - Add @DefaultValue for optional params
   - Inject service with @Inject

3. Validate
   mvn clean compile
   - All endpoints compile
   - All methods return Uni<T>
   - No Spring annotations found
```

**Required Files:**

- `.github/instructions/02-RETROFIT-MIGRATION.md` (endpoint section)
- README.md (Fase 8: REST Endpoints)

**Success Criteria:**

- ✅ All endpoints updated
- ✅ Uni<T> returns
- ✅ Annotations correct
- ✅ Compilation successful

---

### PHASE 9: TESTING

**Agent Actions:**

```
1. Create endpoint tests
   - Use @QuarkusTest
   - Use Rest Assured for HTTP tests
   - Test all GET/POST/PUT/DELETE
   - Validate status codes

2. Create service tests
   - Use @QuarkusTest
   - Mock @RestClient with @InjectMock
   - Test service methods
   - Use UniAssertSubscriber for Uni assertions

3. Run tests
   mvn clean test
   - Ensure all tests pass
   - Check coverage > 80%

4. Fix failing tests
   - Adjust assertions for Uni<T>
   - Fix mock configurations
   - Update test expectations
```

**Required Files:**

- `.github/instructions/06-TESTING.md`
- README.md (Fase 9: Testing)
- copilot-instructions.md (test patterns)

**Success Criteria:**

- ✅ All tests pass
- ✅ Coverage > 80%
- ✅ No @SpringBootTest found
- ✅ Rest Assured used for HTTP tests

---

### PHASE 10: VALIDATION & FINAL

**Agent Actions:**

```
1. Build project
   mvn clean package
   - Check for compilation errors
   - Verify JAR creation
   - Check JAR size < 100MB

2. Run application
   mvn quarkus:dev
   - Verify startup < 2 seconds
   - Check no errors in logs

3. Test endpoints
   curl http://localhost:8080/api/...
   - Test all critical endpoints
   - Verify responses are correct

4. Check resources
   - Memory usage < 200MB
   - Startup time < 2s
   - Swagger UI at /q/swagger-ui

5. Final validation
   - All functionality working
   - Performance improved
   - No Spring dependencies
   - All tests passing

6. Update tracking
   - Complete MIGRATION_CHECKLIST.md
   - Generate MIGRATION_REPORT.md
   - Document any issues/solutions
```

**Required Files:**

- README.md (Fase 10: Validación Final)
- MIGRATION_CHECKLIST.md

**Success Criteria:**

- ✅ Build successful
- ✅ Startup < 2 seconds
- ✅ Memory < 200MB
- ✅ All endpoints working
- ✅ Tests passing
- ✅ No Spring artifacts

---

## 🎮 Agent Control Flow

### Decision Points

**After each phase, agent asks:**

```
Phase {N} completed. Did everything work as expected?

A) Yes, continue to next phase
B) No, there are issues to fix
C) Help, I need assistance
D) Skip this phase (not recommended)
```

### Error Handling

```
IF compilation fails:
├─ Check which file has error
├─ Suggest fix based on phase
├─ Offer to regenerate file
└─ Show similar working example

IF test fails:
├─ Show which test failed
├─ Suggest root cause
├─ Offer to fix test or code
└─ Show test pattern from instructions

IF validation fails:
├─ Check what validation didn't pass
├─ Show checklist item not met
├─ Offer manual or automatic fix
└─ Suggest next step
```

### Rollback

```
IF major issue detected:
├─ Ask to confirm rollback
├─ Revert to last known good state
├─ Show what went wrong
├─ Offer to retry
└─ Provide troubleshooting guide
```

---

## 📊 Progress Tracking

### Tracking File: MIGRATION_STATUS.json

```json
{
  "startDate": "2026-01-30T10:00:00Z",
  "currentPhase": 5,
  "completedPhases": [1, 2, 3, 4],
  "phaseStatus": {
    "1": { "status": "completed", "duration": "15m", "issues": 0 },
    "2": { "status": "completed", "duration": "20m", "issues": 0 },
    "3": { "status": "completed", "duration": "25m", "issues": 0 },
    "4": { "status": "completed", "duration": "30m", "issues": 0 },
    "5": { "status": "in-progress", "duration": "45m", "issues": 1 },
    "6": { "status": "pending", "duration": null, "issues": 0 }
  },
  "metrics": {
    "filesModified": 12,
    "filesCreated": 8,
    "compilationErrors": 0,
    "testsPassing": 45,
    "testsFailing": 2,
    "coverage": 82
  },
  "nextAction": "Fix failing tests in Phase 9"
}
```

---

## 🔧 Agent Commands

### Commands user can give to agent:

```
"Continue migration"
→ Execute next phase

"Skip phase X"
→ Move to phase X+1 (not recommended)

"Go back to phase Y"
→ Rollback to phase Y

"What's the status?"
→ Show MIGRATION_STATUS.json

"Help with phase Z"
→ Provide detailed guidance for phase Z

"Show me the checklist"
→ Display MIGRATION_CHECKLIST.md

"Fix compilation error"
→ Analyze error, suggest fix, apply it

"Run tests"
→ Execute `mvn clean test`, show results

"What's next?"
→ Show next step in current phase

"Review my code"
→ Validate against patterns and rules

"Generate report"
→ Create MIGRATION_REPORT.md
```

---

## 📋 Agent Checklist Template

**Before each phase:**

```
PHASE {N}: {PHASE_NAME}

PRE-REQUISITES:
- [ ] Previous phases completed successfully
- [ ] Required files available
- [ ] User confirmed readiness

EXECUTION:
- [ ] Step 1 completed
- [ ] Step 2 completed
- [ ] Step 3 completed
- [ ] Validation passed

POST-PHASE:
- [ ] All files compiled
- [ ] No new errors introduced
- [ ] Code follows patterns
- [ ] Documentation updated
```

---

## 📚 Resource Organization

### By Phase:

```
Phase 1:  .github/instructions/01-MIGRATION-OVERVIEW.md
Phase 2:  .github/skills/01-quarkus-setup-skill.md
Phase 3:  .github/instructions/01-MIGRATION-OVERVIEW.md (dependencies section)
Phase 4:  .github/skills/03-openapi-generation-skill.md
Phase 5:  .github/skills/02-retrofit-migration-skill.md
          .github/prompts/retrofit-migration-prompt.md
Phase 6:  .github/prompts/reactive-stack-prompt.md
          .github/instructions/04-REACTIVE-STACK.md
Phase 7:  .github/instructions/05-CONFIGURATION.md
Phase 8:  .github/instructions/02-RETROFIT-MIGRATION.md (endpoint section)
Phase 9:  .github/instructions/06-TESTING.md
Phase 10: README.md (Validation section)
```

### Anytime:

```
Reference:      README.md (complete guide)
Copilot Help:   copilot-instructions.md
Checklists:     MIGRATION_CHECKLIST.md
Progress:       MIGRATION_STATUS.json (updated by agent)
Report:         MIGRATION_REPORT.md (generated at end)
```

---

## 🎯 Expected Outcomes

### Per Phase

| Phase | Expected Outcome                | Time      |
| ----- | ------------------------------- | --------- |
| 1     | Project analyzed, plan created  | 15-30 min |
| 2     | Quarkus base created, compiles  | 15 min    |
| 3     | Dependencies updated, compiles  | 30 min    |
| 4     | DTOs generated from OpenAPI     | 30-60 min |
| 5     | REST Client interfaces created  | 1-2 hours |
| 6     | RxJava → Mutiny conversion done | 2-4 hours |
| 7     | Services & config migrated      | 30-60 min |
| 8     | All endpoints migrated          | 1-2 hours |
| 9     | Test suite complete & passing   | 1-2 hours |
| 10    | App running, validated          | 1 hour    |

**Total Time:** 10-13 hours for medium project

### Overall Success Criteria

```
✅ Compilation without errors
✅ All tests passing (coverage > 80%)
✅ Startup < 2 seconds
✅ Memory < 200MB
✅ Feature parity with original
✅ OpenAPI/Swagger functional
✅ No Spring artifacts in code
✅ No RxJava artifacts in code
✅ Documentation complete
✅ MIGRATION_REPORT.md generated
```

---

## 🤖 Agent Persona

**The agent should:**

- ✅ Be proactive in suggesting next steps
- ✅ Be clear about what's happening and why
- ✅ Offer help without being pushy
- ✅ Validate constantly
- ✅ Explain errors in simple terms
- ✅ Provide actionable solutions
- ✅ Track progress visibly
- ✅ Celebrate milestones

**The agent should NOT:**

- ❌ Assume user understands Quarkus
- ❌ Skip validation steps
- ❌ Proceed without user confirmation
- ❌ Hide errors
- ❌ Modify original-spring/ directory
- ❌ Delete user code without warning
- ❌ Rush phases

---

## 📝 Agent Script Example

```
User: "Start my Spring to Quarkus migration"

Agent: "Perfect! I'll guide you through all 10 phases.

        Let me first check your project:

        ✓ Java 17 installed
        ✓ Maven 3.8.1 installed
        ✓ original-spring/ directory found

        I can see:
        - 15 Spring dependencies
        - 8 Retrofit interfaces
        - 3 Observable chains
        - 1 OpenAPI contract

        Would you like me to:
        A) Start Phase 1 (Preparation)
        B) Get more details about your project
        C) Show the complete plan"

User: "A"

Agent: "PHASE 1: PREPARATION

        I'm analyzing your project structure...

        [30 seconds of analysis]

        ✓ Analysis complete

        Found:
        - Controllers: 5
        - Services: 8
        - Retrofit clients: 3
        - Test files: 12

        📄 I've created MIGRATION_PLAN.md

        Ready to continue?

        A) Yes, next phase
        B) Show me the plan
        C) I have questions"
```

---

## 🔐 Data Safety

### Agent Protection:

```
NEVER:
- Modify original-spring/ directory
- Delete files without confirmation
- Overwrite user code without backup
- Run destructive commands
- Commit to git without asking

ALWAYS:
- Show what will be changed
- Ask for confirmation
- Keep backups
- Provide rollback option
- Log all changes
```

---

**Agent Version:** 1.0  
**Last Updated:** 30 de enero de 2026  
**Status:** Ready for Orchestration
