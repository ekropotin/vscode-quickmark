# Contributing to QuickMark VSCode Extension

######

Thank you for your interest in contributing to the QuickMark VSCode extension! This guide will help you get started with development, testing, and contributing to the project.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Node.js](https://nodejs.org/) (v16 or later)
- [npm](https://www.npmjs.com/) (comes with Node.js)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Rust](https://rustup.rs/) (for building the language server)
- [Git](https://git-scm.com/)

## Development Setup

### 1. Clone the Repository

```bash
git clone https://github.com/quickmark/quickmark.git
cd quickmark/vscode-quickmark
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Get QuickMark Server Binaries

The extension requires the `quickmark-server` binary. You have two options:

**Option A: Download from GitHub releases (Recommended)**

```bash
./scripts/download-binaries.sh
```

This automatically downloads the correct binaries for all platforms from the GitHub releases.

**Option B: Build from source**

```bash
cd ..  # Go to project root
cargo build --release --bin quickmark-server
```

Then manually copy the built binary to the `bin/` directory with the correct platform-specific name.

### 5. Compile TypeScript

```bash
npm run compile
```

## Development Workflow

### Running the Extension

1. **Open the extension project in VSCode:**

   ```bash
   code .
   ```

2. **Start development mode:**
   - Press `F5` or use the "Run Extension" launch configuration
   - This opens a new VSCode window (Extension Development Host) with your extension loaded

3. **Test the extension:**
   - In the new window, open or create a Markdown file (`.md`)
   - The extension should automatically start and begin linting
   - Check the Output panel (`View > Output > QuickMark`) for logs

### Making Changes

1. **TypeScript changes:**

   ```bash
   # Option 1: Compile once
   npm run compile

   # Option 2: Watch mode (auto-compile on changes)
   npm run watch
   ```

2. **After making changes:**
   - Press `Ctrl+R` (or `Cmd+R` on Mac) in the Extension Development Host window to reload
   - Or restart the debugging session (`Ctrl+Shift+F5`)

3. **Server changes:**
   - If you modify the `quickmark-server` Rust code:

     ```bash
     cd .. && cargo build --release --bin quickmark-server
     ```

   - Manually copy the binary to `bin/` with correct naming
   - Restart the extension development session

## Testing

### Manual Testing

1. **Create test Markdown files** with various linting issues:

   ```markdown
   # Test Document

   This line is way too long and exceeds the default 80 character limit which should trigger MD013

   ### This heading skips H2 (should trigger MD001)

   ## Duplicate Heading
   ## Duplicate Heading
   ```

2. **Test different scenarios:**
   - Files with various rule violations
   - Configuration files (`quickmark.toml`)
   - Different file extensions (`.markdown`, `.mdown`, etc.)
   - Workspace folders and multi-root workspaces

### Automated Testing

```bash
# Run linting
npm run lint

# Run tests (when available)
npm test
```

## Building and Packaging

### Development Build

```bash
# Compile TypeScript
npm run compile

# Get binaries (choose one):
./scripts/download-binaries.sh  # Download from releases
# OR build from source and copy manually
```

### Production Package

```bash
# Create VSIX package for installation
npm run package
```

This creates a `.vsix` file that can be installed in VSCode.

### Cross-Platform Release Build

For creating a release with all platform binaries:

```bash
# Download binaries from GitHub releases
./scripts/download-binaries.sh

# Package extension with all binaries
npm run package
```

The `download-binaries.sh` script automatically:
- Reads the server version from `package.json` (`quickmarkServer.version`)
- Downloads platform-specific binaries from GitHub releases
- Extracts and names them correctly for the extension

## Installing Your Build

### Method 1: VSIX Installation

1. Build the package: `npm run package`
2. Install via Command Palette: `Extensions: Install from VSIX...`
3. Select the generated `.vsix` file

### Method 2: Command Line Installation

```bash
code --install-extension vscode-quickmark-0.0.1.vsix
```

### Method 3: Development Symlink

```bash
# Find VSCode extensions directory
# Windows: %USERPROFILE%\.vscode\extensions
# macOS/Linux: ~/.vscode/extensions

# Create symlink (example for macOS/Linux)
ln -s $(pwd) ~/.vscode/extensions/quickmark.vscode-quickmark-dev
```

## Code Style and Standards

### TypeScript

- Follow the ESLint configuration (`.eslintrc.json`)
- Use strict TypeScript settings
- Prefer modern async/await over callbacks
- Use meaningful variable and function names

### Code Quality

```bash
# Run linting
npm run lint

# Fix auto-fixable issues
npx eslint src --ext ts --fix
```

## Project Structure

```
vscode-quickmark/
├── src/
│   └── extension.ts          # Main extension code
├── bin/                      # Bundled binaries (generated)
├── scripts/
│   └── download-binaries.sh   # Downloads release binaries
├── .vscode/
│   ├── launch.json          # Debug configurations
│   └── tasks.json           # Build tasks
├── package.json             # Extension manifest
├── tsconfig.json           # TypeScript configuration
├── .eslintrc.json          # ESLint configuration
└── README.md               # User documentation
```

## Extension Architecture

### Key Components

1. **Extension Activation**: Triggered when opening Markdown files
2. **Binary Resolution**: Automatically finds bundled or custom server binary
3. **LSP Client**: Communicates with `quickmark_server` via Language Server Protocol
4. **Configuration**: Handles VSCode settings and `quickmark.toml` files
5. **Commands**: Restart server, show output, etc.

### Important Functions

- `getBundledServerPath()`: Platform-specific binary detection (expects `quickmark-server-*` naming)
- `startLanguageServer()`: LSP client initialization
- `restartServer()`: Server restart functionality

## Contributing Guidelines

### Before Submitting

1. **Test thoroughly** on your platform
2. **Run linting**: `npm run lint`
3. **Update documentation** if needed
4. **Follow existing code style**

### Pull Request Process

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature`
3. **Make your changes** and test them
4. **Commit with clear messages**: Follow [conventional commits](https://www.conventionalcommits.org/)
5. **Push to your fork**: `git push origin feature/your-feature`
6. **Open a pull request** with a clear description

### Commit Message Format

```
type(scope): description

Examples:
feat(extension): add support for custom server binary paths
fix(binary): correct platform detection for Apple Silicon
docs(readme): update installation instructions
```

## Debugging

### Extension Debugging

1. Set breakpoints in TypeScript code
2. Press `F5` to start debugging
3. Use the Debug Console in VSCode

### Server Communication Debugging

1. Enable trace logging in settings:

   ```json
   {
     "quickmark.trace.server": "verbose"
   }
   ```

2. Check the Output panel for detailed LSP communication

### Common Issues

1. **Binary not found**: Ensure you've run `./scripts/download-binaries.sh` or built from source
2. **Server won't start**: Check Output panel for error messages
3. **Extension not loading**: Verify `package.json` activation events
4. **TypeScript errors**: Run `npm run compile` to see detailed errors

## Release Process

1. **Update version** in `package.json`
2. **Update CHANGELOG.md** with new features/fixes
3. **Build all platform binaries**: `npm run build-binaries`
4. **Test on multiple platforms**
5. **Create release package**: `npm run package`
6. **Tag the release**: `git tag v0.0.2`
7. **Publish to marketplace**: `vsce publish`

## Getting Help

- **Issues**: Report bugs and feature requests on GitHub Issues
- **Discussions**: Use GitHub Discussions for questions
- **Documentation**: Check the main QuickMark project documentation

## License

By contributing to this project, you agree that your contributions will be licensed under the same license as the project.
