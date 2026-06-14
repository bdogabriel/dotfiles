# ADF (Atlassian Document Format) Guidelines

## What is ADF?
ADF is Jira's structured format for rich text content in fields like descriptions, comments, and custom fields. It uses JSON structure to define formatting, lists, tables, and other content elements.

## Basic ADF Structure
```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Your content here"
        }
      ]
    }
  ]
}
```

## Common ADF Patterns

### Simple Text with Formatting
```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "This is ",
          "marks": []
        },
        {
          "type": "text",
          "text": "bold text",
          "marks": [{"type": "strong"}]
        },
        {
          "type": "text",
          "text": " and this is ",
          "marks": []
        },
        {
          "type": "text",
          "text": "italic",
          "marks": [{"type": "em"}]
        }
      ]
    }
  ]
}
```

### Bulleted List
```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [{"type": "text", "text": "First item"}]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [{"type": "text", "text": "Second item"}]
            }
          ]
        }
      ]
    }
  ]
}
```

### Numbered List
```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "orderedList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [{"type": "text", "text": "Step 1"}]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [{"type": "text", "text": "Step 2"}]
            }
          ]
        }
      ]
    }
  ]
}
```

### Code Block
```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "codeBlock",
      "attrs": {"language": "javascript"},
      "content": [
        {
          "type": "text",
          "text": "function example() {\n  console.log('Hello World');\n}"
        }
      ]
    }
  ]
}
```

### Table Structure
```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "table",
      "attrs": {"isNumberColumnEnabled": false},
      "content": [
        {
          "type": "tableRow",
          "content": [
            {
              "type": "tableHeader",
              "content": [
                {
                  "type": "paragraph",
                  "content": [{"type": "text", "text": "Header 1"}]
                }
              ]
            },
            {
              "type": "tableHeader",
              "content": [
                {
                  "type": "paragraph",
                  "content": [{"type": "text", "text": "Header 2"}]
                }
              ]
            }
          ]
        },
        {
          "type": "tableRow",
          "content": [
            {
              "type": "tableCell",
              "content": [
                {
                  "type": "paragraph",
                  "content": [{"type": "text", "text": "Cell 1"}]
                }
              ]
            },
            {
              "type": "tableCell",
              "content": [
                {
                  "type": "paragraph",
                  "content": [{"type": "text", "text": "Cell 2"}]
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

# ADF Best Practices

1. **Always validate ADF JSON** before using in commands
2. **Use appropriate content types** (paragraph, bulletList, orderedList, codeBlock, etc.)
3. **Structure content logically** with proper nesting
4. **Include version field** (always use version: 1)
5. **Use marks for formatting** (strong, em, code, etc.)
6. **Escape special characters** properly in JSON strings
7. **Test with simple content first** before complex formatting
8. **Keep ADF structure flat** when possible for better readability
9. **Use consistent formatting** across similar issues
10. **Document ADF templates** for reusable patterns

# Common ADF Elements Reference

| Element Type | Usage | Example |
|-------------|--------|---------|
| `paragraph` | Basic text container | `{"type": "paragraph", "content": [...]}` |
| `text` | Text node with optional marks | `{"type": "text", "text": "content", "marks": [...]}` |
| `strong` | Bold formatting mark | `{"type": "strong"}` |
| `em` | Italic formatting mark | `{"type": "em"}` |
| `code` | Inline code mark | `{"type": "code"}` |
| `bulletList` | Unordered list | `{"type": "bulletList", "content": [...]}` |
| `orderedList` | Numbered list | `{"type": "orderedList", "content": [...]}` |
| `listItem` | List item container | `{"type": "listItem", "content": [...]}` |
| `codeBlock` | Code block with language | `{"type": "codeBlock", "attrs": {"language": "..."}}` |
| `table` | Table structure | `{"type": "table", "content": [...]}` |
