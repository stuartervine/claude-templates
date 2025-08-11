## PYTHON RULES

### General rules
- Use Python 3.11 or greater
- Use Python Types

### File and Class Naming

- Name files as `<object_name>.py` (e.g., `file_store.py`)
- File names should represent their implementation and interface. For example:
  - We may have a `Store` protocol in a `store.py` file.
  - An implementation of `FileStore` in a `file_store.py` file.
  - And an implementation of `InMemoryStore` in an `in_memory_store.py` file.
  - All stores live in the `store` package & folder.
- Each file should contain a single implementation focused on one domain concept
- Group related implementations in appropriate packages (e.g., `testing` for test doubles)
- Avoid generic terms like "Test" or "Mock" or "Impl" in the class name
- Avoid pattern names e.g. `AbstractFileFactory` and use more behavioural names e.g. `FileCreator`.

### Composition

Prefer composing objects instead of long method implementations.
- In general more objects with shorter methods are a good thing.
- Objects should focus on a single responsibility
- Methods should be clearly named and easy to understand what they do. 
- Prefer clarity over terseness.

### In Memory Testing Objects

**CRITICAL: IN-MEMORY IMPLEMENTATIONS SHOULD FOLLOW A CLEAR NAMING CONVENTION.** 

1. **In-memory implementation files**
   - Name files as `in_memory_<object_name>.py` (e.g., `in_memory_browser.py`)

2. **In-memory implementation classes**
   - Name classes as `InMemory<ObjectName>` (e.g., `InMemoryBrowser`)
   - The class name should reflect its domain purpose, not implementation details

3. **Implementation behavior**
   - In-memory implementations should behave like the real implementations but without external dependencies
   - They should provide additional methods for test verification and setup
   - All functionality relevant to tests should be fully implemented

This naming convention makes the purpose of test implementations immediately clear and ensures consistency throughout the codebase.

### Virtual Environment
- **ALWAYS** activate the virtual environment before running any Python commands
  - Use `source .venv/bin/activate` before running pip, pytest, or python
  - Never run Python commands with the system Python interpreter
  - Check that the virtual environment is activated before installing packages
  - Use the activated environment for all development operations

### Package Management
- Install the project in development mode after making code changes: `pip install -e .`
- Run tests from the project root with the virtual environment activated
- Use the project's specified package manager (uv) for installing dependencies
- Verify package dependencies match those in pyproject.toml

### Naming Conventions

**VERY IMPORTANT: Naming of files and classes is critical.** Do not name classes and files with language implementation details such as "Interface" or "Class".

- Domain abstractions should be named using domain-specific terms
- Files containing interfaces should be named after the domain concept (e.g., `storage.py`)
- Implementation classes should be named with their specific implementation type (e.g., `S3Storage`)
- Implementation files should be named with the specific implementation prefix (e.g., `s3_storage.py`)

Example:
- Interface: `Storage` in file `storage.py`
- Implementation: `S3Storage` in file `s3_storage.py`

### Testing: Behaviour driven tests

We prefer simplicity when reading tests:
- You should create builders & helper functions / classes to remove boiler plate & noisy code and make it easier for developers to understand the intention of the code.
  - For any object that is being used as part of an assertion - create it in the test method, not in a helper. 
- These helpers should be created in the test file, unless they are to be shared across tests.
  - DO NOT chain helper methods. 
- For builders that help create complex objects, create these in a separate file of <object name>_builder.py
  - DO chain builder methods.  
- The name of the test should be simple and to the point.
- You should not need to insert comments into tests - they should be easily understood without the comments.
- ALWAYS update tests in place; do not create new files with suffixes like "_refactored" or "_updated".
- Maintain backward compatibility with existing test imports and module structure when refactoring.
- **NEVER create new test files when existing ones already exist.** If `test_analyzer.py` exists, modify it instead of creating `test_analyzer_refactored.py` or similar.
- When refactoring or updating tests, edit the existing test file directly to maintain consistency and avoid test file proliferation.

This sort of test is bad:

```python
def test_workflow_with_url_and_actions_produces_expected_structure() -> None:
    """Test that a workflow with URL and actions produces the expected structure."""
    # Create a workflow with URL and actions
    test_url = "https://example.com"
    llm_thing = InMemoryLLMThing()
    recorder = WorkflowRecorder(start_url=test_url, llm_thing=llm_thing)
    
    click_action: Action = {"type": "click", "selector": "#button1"}
    fill_action: Action = {"type": "fill", "selector": "#input1", "value": "test"}
    
    recorder = recorder.add_action(click_action).add_action(fill_action)
    
    # Get the workflow and verify its structure
    workflow = recorder.get_workflow()
    assert workflow["start_url"] == test_url
    assert len(workflow["actions"]) == 2
    assert workflow["actions"][0]["type"] == "click"
    assert workflow["actions"][1]["type"] == "fill"
    assert llm_thing.received_prompt("Some text")
```

This sort of test is better:
```python
def test_records_a_workflow() -> None:
    test_url = "https://example.com"
    click_action: Action = {"type": "click", "selector": "#button1"}
    fill_action: Action = {"type": "fill", "selector": "#input1", "value": "test"}
    
    llm_thing = InMemoryLLMThing()
    recorder = recorder_with(start_url=test_url, llm_thing=llm_thing, action=[click_action, fill_action])
    workflow = recorder.get_workflow()
    
    workflow_assertions = assert_workflow(workflow)
    assert workflow_assertions.has_url(test_url)
    assert workflow_assertions.contains_actions([click_action, fill_action])
    assert llm_thing.received_prompt("Some text")
 ```


This naming convention ensures that your code reflects the domain model rather than the technical implementation details, making the code more readable and maintainable.
