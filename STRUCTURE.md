# Code structure guidelines

## Working Software and Iterative Development

**CRITICAL: WORKING SOFTWARE OVER FEATURES.** Prioritize having a runnable system from the first line of code. All components should be wired together into a working end-to-end system as early as possible.

- Work in small, manageable increments
- Add the minimal amount of code needed for each feature
- Maintain a working state throughout development
- Build vertical slices (end-to-end functionality) rather than horizontal layers
- Ensure the core application can always be run, even with limited functionality
- Prioritize integrating components into a working system over adding new features
- Test the complete system regularly, not just individual components

## Task Management
- Break down large tasks into smaller, actionable items
- Check off completed items as progress is made

## Code Quality

### Self-Documenting Code

- Code should document itself through clear naming and structure
- Choose descriptive names for classes, methods, and variables that reveal intention
- Avoid redundant comments that merely restate what the code already says
- Use comments sparingly and only when they add value beyond what the code itself expresses
- Comments should explain WHY, not WHAT or HOW
- Structure code to make its purpose and flow immediately obvious
- Extract complex logic into independent objects or well-named functions with clear inputs and outputs
- Prefer better code structure over explanatory comments

### General Quality
- Write clean, maintainable code
- Focus on readability and simplicity
- Refactor regularly to prevent technical debt

## Immutability and State Management

- Prefer immutable data structures and pure functions
- Avoid mutable state where possible
- Design classes with immutability in mind:
  - Use constructor parameters for required state instead of setters
  - Return new instances instead of modifying existing ones
  - Make methods return new objects rather than modifying internal state
- Avoid getters and setters that expose or modify internal state
- Use functional programming patterns where appropriate
- Test outputs and behaviors, not internal structure

## Build and Deployment
- Maintain simple, parameterized commands for all operations:
  - Build
  - Run tests
  - Run application
  - Deploy
